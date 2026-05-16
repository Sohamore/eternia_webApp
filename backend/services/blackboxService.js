const prisma = require('../prisma/client');
const axios = require('axios');
const logger = require('../utils/logger');

async function getEntries(userId, cursor, limit = 30) {
  const where = { user_id: userId };
  if (cursor) {
    where.created_at = { lt: new Date(cursor) };
  }

  const entries = await prisma.blackboxEntry.findMany({
    where,
    orderBy: { created_at: 'desc' },
    take: limit + 1,
  });

  const hasMore = entries.length > limit;
  return { entries: hasMore ? entries.slice(0, limit) : entries, hasMore };
}

async function createEntry(userId, content, contentType = 'text', isPrivate = false) {
  const entry = await prisma.blackboxEntry.create({
    data: {
      user_id: userId,
      content_encrypted: content,
      content_type: contentType,
      is_private: isPrivate,
      ai_flag_level: 0,
    }
  });
  return entry;
}

async function deleteEntry(userId, entryId) {
  const entry = await prisma.blackboxEntry.findFirst({
    where: { id: entryId, user_id: userId }
  });
  if (!entry) throw Object.assign(new Error('Entry not found'), { status: 404 });
  await prisma.blackboxEntry.delete({ where: { id: entryId } });
  return { success: true };
}

async function moderateEntry(userId, entryId) {
  const entry = await prisma.blackboxEntry.findFirst({
    where: { id: entryId, user_id: userId }
  });
  if (!entry) throw Object.assign(new Error('Entry not found'), { status: 404 });
  if (entry.is_private) return { flag_level: 0, skipped: true };

  try {
    const response = await axios.post(
      `${process.env.AI_GATEWAY_URL || 'https://api.openai.com/v1'}/chat/completions`,
      {
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: `You are a mental health AI moderator. Classify the following journal entry's distress level. Respond with ONLY a single digit: 0 (normal), 1 (mild distress), 2 (moderate concern), 3 (critical/crisis). Nothing else.`
          },
          { role: 'user', content: entry.content_encrypted }
        ],
        max_tokens: 5,
        temperature: 0,
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.AI_GATEWAY_KEY}`,
          'Content-Type': 'application/json',
        },
        timeout: 10000,
      }
    );

    const text = response.data.choices?.[0]?.message?.content?.trim();
    const flagLevel = parseInt(text, 10);
    const validLevel = [0, 1, 2, 3].includes(flagLevel) ? flagLevel : 0;

    await prisma.blackboxEntry.update({
      where: { id: entryId },
      data: { ai_flag_level: validLevel }
    });

    return { flag_level: validLevel };
  } catch (err) {
    logger.error('AI moderation failed:', err.message);
    return { flag_level: 0, error: 'AI unavailable' };
  }
}

// BlackBox Sessions (anonymous therapy)
async function getDailyCount(userId) {
  const startOfDay = new Date();
  startOfDay.setHours(0, 0, 0, 0);

  return prisma.blackboxSession.count({
    where: {
      student_id: userId,
      created_at: { gte: startOfDay }
    }
  });
}

async function getUsageCount(userId) {
  return prisma.blackboxSession.count({ where: { student_id: userId } });
}

async function getActiveSessions(userId) {
  return prisma.blackboxSession.findMany({
    where: {
      student_id: userId,
      status: { in: ['queued', 'accepted', 'active'] }
    },
    orderBy: { created_at: 'desc' },
    take: 1,
  });
}

async function getSessionById(sessionId) {
  return prisma.blackboxSession.findUnique({ where: { id: sessionId } });
}

async function createSession(userId) {
  const dailyCount = await getDailyCount(userId);
  if (dailyCount >= 3) {
    throw Object.assign(new Error('Daily BlackBox limit reached (3 sessions/day)'), { status: 429 });
  }

  const existing = await getActiveSessions(userId);
  if (existing.length > 0) return { session: existing[0], reconnected: true };

  const session = await prisma.blackboxSession.create({
    data: { student_id: userId, status: 'queued' }
  });
  return { session, reconnected: false };
}

async function cancelSession(userId, sessionId) {
  const session = await prisma.blackboxSession.findFirst({
    where: { id: sessionId, student_id: userId }
  });
  if (!session) throw Object.assign(new Error('Session not found'), { status: 404 });

  await prisma.blackboxSession.update({
    where: { id: sessionId },
    data: { status: 'cancelled', ended_at: new Date() }
  });

  // Refund if never joined
  if (!session.student_joined_at) {
    const spendTx = await prisma.creditTransaction.findFirst({
      where: { reference_id: sessionId, type: 'spend' }
    });
    if (spendTx) {
      const refundAmount = Math.abs(spendTx.delta);
      const existingRefund = await prisma.creditTransaction.findFirst({
        where: { reference_id: sessionId, type: 'grant' }
      });
      if (!existingRefund && refundAmount > 0) {
        await prisma.creditTransaction.create({
          data: {
            user_id: userId,
            delta: refundAmount,
            type: 'grant',
            notes: 'BlackBox session cancelled — refund',
            reference_id: sessionId,
          }
        });
      }
    }
  }

  return { success: true };
}

async function endSession(sessionId, userId) {
  const session = await prisma.blackboxSession.findFirst({
    where: { id: sessionId }
  });
  if (!session) throw Object.assign(new Error('Session not found'), { status: 404 });

  await prisma.blackboxSession.update({
    where: { id: sessionId },
    data: { status: 'completed', ended_at: new Date() }
  });
  return { success: true };
}

async function updateSessionJoin(sessionId, userId) {
  await prisma.blackboxSession.update({
    where: { id: sessionId },
    data: { student_joined_at: new Date(), last_join_error: null }
  });
  return { success: true };
}

async function updateSessionError(sessionId, errorMsg) {
  await prisma.blackboxSession.update({
    where: { id: sessionId },
    data: { last_join_error: errorMsg }
  });
  return { success: true };
}

// Therapist/Expert actions
async function getTherapistQueue() {
  const sessions = await prisma.blackboxSession.findMany({
    where: { status: 'queued' },
    orderBy: { created_at: 'asc' },
    take: 50,
  });
  const profileIds = sessions.map(s => s.student_id);
  const profiles = await prisma.profile.findMany({
    where: { id: { in: profileIds } },
    select: { id: true, username: true }
  });
  const profileMap = new Map(profiles.map(p => [p.id, p.username]));
  return sessions.map(s => ({
    ...s,
    student_username: profileMap.get(s.student_id) || "Anonymous"
  }));
}

async function getTherapistActive(therapistId) {
  return prisma.blackboxSession.findMany({
    where: { therapist_id: therapistId, status: { in: ['accepted', 'active', 'escalated'] } },
    take: 1
  });
}

async function getTherapistHistory(therapistId) {
  return prisma.blackboxSession.findMany({
    where: { therapist_id: therapistId, status: { in: ['completed', 'escalated'] } },
    orderBy: { created_at: 'desc' },
    take: 50
  });
}

async function acceptSessionByTherapist(sessionId, therapistId, roomId) {
  const session = await prisma.blackboxSession.findFirst({
    where: { id: sessionId, status: 'queued' }
  });
  if (!session) throw Object.assign(new Error('Session was already claimed or does not exist'), { status: 400 });

  return prisma.blackboxSession.update({
    where: { id: sessionId },
    data: {
      therapist_id: therapistId,
      status: 'accepted',
      room_id: roomId,
      started_at: new Date()
    }
  });
}

async function escalateSessionByTherapist(sessionId, therapistId, level, reason) {
  const session = await prisma.blackboxSession.findFirst({
    where: { id: sessionId, therapist_id: therapistId }
  });
  if (!session) throw Object.assign(new Error('Session not found'), { status: 404 });

  const historyEntry = { level, reason, timestamp: new Date().toISOString() };
  let updatedHistory = [];
  try {
    updatedHistory = Array.isArray(session.escalation_history) ? session.escalation_history : (session.escalation_history ? JSON.parse(session.escalation_history) : []);
  } catch (e) {
    updatedHistory = [];
  }
  updatedHistory.push(historyEntry);

  const newStatus = level >= 3 ? 'escalated' : 'active';

  const updatedSession = await prisma.blackboxSession.update({
    where: { id: sessionId },
    data: {
      flag_level: level,
      escalation_reason: reason,
      escalation_history: updatedHistory,
      status: newStatus
    }
  });

  await prisma.auditLog.create({
    data: {
      actor_id: therapistId,
      action_type: 'escalation_submitted',
      target_table: 'blackbox_sessions',
      target_id: sessionId,
      metadata: { level, reason_length: reason.length }
    }
  });

  return updatedSession;
}

async function saveSessionNotes(sessionId, therapistId, notes) {
  return prisma.blackboxSession.update({
    where: { id: sessionId, therapist_id: therapistId },
    data: { session_notes_encrypted: notes }
  });
}

async function updateTherapistJoin(sessionId, therapistId) {
  return prisma.blackboxSession.update({
    where: { id: sessionId, therapist_id: therapistId },
    data: { therapist_joined_at: new Date() }
  });
}

module.exports = {
  getEntries, createEntry, deleteEntry, moderateEntry,
  getDailyCount, getUsageCount, getActiveSessions, getSessionById,
  createSession, cancelSession, endSession, updateSessionJoin, updateSessionError,
  getTherapistQueue, getTherapistActive, getTherapistHistory, acceptSessionByTherapist,
  escalateSessionByTherapist, saveSessionNotes, updateTherapistJoin
};
