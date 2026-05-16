const prisma = require('../prisma/client');
const logger = require('../utils/logger');

async function getBalance(userId) {
  const agg = await prisma.creditTransaction.aggregate({
    where: { user_id: userId },
    _sum: { delta: true }
  });
  return agg._sum.delta || 0;
}

async function getWeeklyEarnTotal(userId) {
  const now = new Date();
  const dayOfWeek = now.getDay();
  const startOfWeek = new Date(now);
  startOfWeek.setDate(now.getDate() - (dayOfWeek === 0 ? 6 : dayOfWeek - 1));
  startOfWeek.setHours(0, 0, 0, 0);

  const agg = await prisma.creditTransaction.aggregate({
    where: {
      user_id: userId,
      type: 'earn',
      created_at: { gte: startOfWeek }
    },
    _sum: { delta: true }
  });
  return agg._sum.delta || 0;
}

async function getTransactions(userId, limit = 50) {
  return prisma.creditTransaction.findMany({
    where: { user_id: userId },
    orderBy: { created_at: 'desc' },
    take: limit,
  });
}

async function earnCredits(userId, amount, notes, referenceId) {
  // Enforce 5 ECC/week cap
  const weeklyTotal = await getWeeklyEarnTotal(userId);
  const WEEKLY_CAP = 5;
  const remaining = Math.max(0, WEEKLY_CAP - weeklyTotal);
  const actualAmount = Math.min(amount, remaining);

  if (actualAmount <= 0) {
    return { success: false, reason: 'weekly_cap_reached', weeklyTotal, cap: WEEKLY_CAP };
  }

  const tx = await prisma.creditTransaction.create({
    data: {
      user_id: userId,
      delta: actualAmount,
      type: 'earn',
      notes: notes || null,
      reference_id: referenceId || null,
    }
  });

  const newBalance = await getBalance(userId);
  return { success: true, amount: actualAmount, balance: newBalance, transaction: tx };
}

async function spendCreditsAtomic(userId, amount, notes, referenceId) {
  return prisma.$transaction(async (tx) => {
    const agg = await tx.creditTransaction.aggregate({
      where: { user_id: userId },
      _sum: { delta: true }
    });
    const balance = agg._sum.delta || 0;

    // Try institution pool if insufficient
    let source = 'personal';
    if (balance < amount) {
      // Get user's institution
      const profile = await tx.profile.findUnique({
        where: { id: userId },
        select: { institution_id: true }
      });

      if (profile?.institution_id) {
        const pool = await tx.eccStabilityPool.findUnique({
          where: { institution_id: profile.institution_id }
        });
        if (pool && pool.balance >= amount) {
          await tx.eccStabilityPool.update({
            where: { institution_id: profile.institution_id },
            data: { balance: { decrement: amount }, total_disbursed: { increment: amount } }
          });
          source = 'institution_pool';
        } else {
          return { success: false, reason: 'insufficient_balance', balance };
        }
      } else {
        return { success: false, reason: 'insufficient_balance', balance };
      }
    }

    const transaction = await tx.creditTransaction.create({
      data: {
        user_id: userId,
        delta: -amount,
        type: 'spend',
        notes: notes || null,
        reference_id: referenceId || null,
      }
    });

    const newBalance = await tx.creditTransaction.aggregate({
      where: { user_id: userId },
      _sum: { delta: true }
    });

    return {
      success: true,
      source,
      remaining: newBalance._sum.delta || 0,
      transaction,
    };
  });
}

async function grantCredits(actorId, actorRole, username, amount, institutionId) {
  if (!['admin', 'spoc'].includes(actorRole)) {
    throw Object.assign(new Error('Unauthorized'), { status: 403 });
  }
  if (amount < 1 || amount > 10000) {
    throw Object.assign(new Error('Amount must be between 1 and 10,000'), { status: 400 });
  }

  const whereClause = { username: username.toLowerCase() };
  if (actorRole === 'spoc') {
    const actorProfile = await prisma.profile.findUnique({ where: { id: actorId } });
    if (actorProfile?.institution_id) {
      whereClause.institution_id = actorProfile.institution_id;
    }
  }

  const target = await prisma.profile.findFirst({ where: whereClause });
  if (!target) throw Object.assign(new Error('Student not found'), { status: 404 });
  if (target.role !== 'student') throw Object.assign(new Error('Can only grant credits to students'), { status: 400 });

  const tx = await prisma.creditTransaction.create({
    data: {
      user_id: target.id,
      delta: amount,
      type: 'grant',
      institution_id: institutionId || null,
      notes: `Granted by ${actorRole}`,
    }
  });

  // Audit log
  await prisma.auditLog.create({
    data: {
      actor_id: actorId,
      action_type: 'credits_granted',
      target_table: 'credit_transactions',
      target_id: tx.id,
      metadata: { amount, recipient: target.id, username },
    }
  });

  return { success: true, transaction: tx };
}

async function grantCreditsBulk(actorId, institutionId, amount) {
  const students = await prisma.profile.findMany({
    where: { institution_id: institutionId, role: 'student', is_active: true },
    select: { id: true }
  });

  if (students.length === 0) return { success: true, count: 0 };

  await prisma.creditTransaction.createMany({
    data: students.map((s) => ({
      user_id: s.id,
      delta: amount,
      type: 'grant',
      institution_id: institutionId,
      notes: 'Bulk grant by admin',
    }))
  });

  await prisma.auditLog.create({
    data: {
      actor_id: actorId,
      action_type: 'bulk_credits_granted',
      target_table: 'credit_transactions',
      metadata: { amount, institution_id: institutionId, count: students.length },
    }
  });

  return { success: true, count: students.length };
}

async function createRazorpayOrder(userId, credits) {
  const CREDIT_PACKAGES = [
    { credits: 25, amountPaise: 4900 },
    { credits: 60, amountPaise: 9900 },
    { credits: 130, amountPaise: 19900 },
  ];

  const pkg = CREDIT_PACKAGES.find((p) => p.credits === credits);
  if (!pkg) throw Object.assign(new Error('Invalid credit package'), { status: 400 });

  const Razorpay = require('razorpay');
  const razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
  });

  const order = await razorpay.orders.create({
    amount: pkg.amountPaise,
    currency: 'INR',
    receipt: `ecc_${userId.slice(0, 8)}_${Date.now()}`,
    notes: { user_id: userId, credits: credits.toString() },
  });

  return { order_id: order.id, amount: pkg.amountPaise, key_id: process.env.RAZORPAY_KEY_ID };
}

async function verifyRazorpayPayment(userId, paymentId, orderId, signature) {
  const crypto = require('crypto');
  const expectedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
    .update(`${orderId}|${paymentId}`)
    .digest('hex');

  if (expectedSignature !== signature) {
    throw Object.assign(new Error('Invalid payment signature'), { status: 400 });
  }

  // Idempotency check
  const existing = await prisma.creditTransaction.findFirst({
    where: { notes: { contains: paymentId } }
  });
  if (existing) return { success: true, message: 'Payment already processed' };

  const Razorpay = require('razorpay');
  const razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
  });

  const order = await razorpay.orders.fetch(orderId);
  if (order.notes.user_id !== userId) {
    throw Object.assign(new Error('Order does not belong to this user'), { status: 403 });
  }

  const credits = parseInt(order.notes.credits, 10);
  await prisma.creditTransaction.create({
    data: {
      user_id: userId,
      delta: credits,
      type: 'purchase',
      notes: `Razorpay payment ${paymentId}`,
    }
  });

  return { success: true, credits };
}

module.exports = {
  getBalance, getWeeklyEarnTotal, getTransactions, earnCredits,
  spendCreditsAtomic, grantCredits, grantCreditsBulk,
  createRazorpayOrder, verifyRazorpayPayment
};
