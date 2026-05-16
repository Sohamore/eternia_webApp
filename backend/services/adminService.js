const prisma = require('../prisma/client');
const bcrypt = require('bcryptjs');
const { generateInstCode, generateStudentId } = require('../utils/helpers');

async function getMembers(actorRole, actorInstitutionId, searchTerm) {
  const where = {};
  if (actorRole === 'spoc' && actorInstitutionId) {
    where.institution_id = actorInstitutionId;
  }
  if (searchTerm) {
    where.username = { contains: searchTerm, mode: 'insensitive' };
  }
  return prisma.profile.findMany({
    where,
    select: {
      id: true, username: true, role: true, is_active: true,
      is_verified: true, total_sessions: true, streak_days: true,
      created_at: true, institution_id: true, specialty: true, student_id: true,
      training_status: true
    },
    orderBy: { created_at: 'desc' },
    take: searchTerm ? 20 : 100
  });
}

async function getStats(actorRole, actorInstitutionId) {
  const isSuperAdmin = actorRole === 'admin';
  const instFilter = isSuperAdmin ? {} : { institution_id: actorInstitutionId };

  const [
    studentCount, appointmentCount, peerCount, blackboxCount,
    pendingEscalations, institutionCount, creditTxs, recentSignups
  ] = await Promise.all([
    prisma.profile.count({ where: { role: 'student', ...instFilter } }),
    prisma.appointment.count(),
    prisma.peerSession.count(),
    prisma.blackboxSession.count(),
    prisma.escalationRequest.count({ where: { status: 'pending' } }),
    prisma.institution.count({ where: { is_active: true } }),
    prisma.creditTransaction.findMany({ select: { delta: true, type: true } }),
    prisma.profile.count({
      where: {
        ...instFilter,
        created_at: { gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) }
      }
    })
  ]);

  const totalCreditsEarned = creditTxs.filter(t => t.delta > 0).reduce((s, t) => s + t.delta, 0);
  const totalCreditsSpent = Math.abs(creditTxs.filter(t => t.delta < 0).reduce((s, t) => s + t.delta, 0));

  const appts = await prisma.appointment.findMany({ select: { status: true } });
  const appointmentsByStatus = appts.reduce((acc, a) => {
    acc[a.status] = (acc[a.status] || 0) + 1;
    return acc;
  }, {});

  return {
    totalStudents: studentCount,
    totalSessions: appointmentCount + peerCount + blackboxCount,
    totalCreditsIssued: totalCreditsEarned,
    activeToday: recentSignups,
    blackboxCount,
    pendingEscalations,
    totalCreditsEarned,
    totalCreditsSpent,
    recentSignups,
    institutionCount,
    appointmentsByStatus,
    appointmentCount,
    peerCount,
  };
}

async function createMember(actorId, actorRole, actorInstitutionId, memberData) {
  const { username, password, role, institution_id, specialty } = memberData;

  if (!username || !password || !role) {
    throw Object.assign(new Error('username, password, and role required'), { status: 400 });
  }

  if (actorRole === 'spoc') {
    if (role !== 'student') throw Object.assign(new Error('SPOCs can only create students'), { status: 403 });
    if (institution_id && institution_id !== actorInstitutionId) {
      throw Object.assign(new Error('Cannot create members for other institutions'), { status: 403 });
    }
  }

  const email = `${username.toLowerCase()}@eternia.local`;
  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) throw Object.assign(new Error('Username already taken'), { status: 409 });

  const password_hash = await bcrypt.hash(password, 12);
  const effectiveInstitutionId = institution_id || (actorRole === 'spoc' ? actorInstitutionId : null);

  let studentId = null;
  if (role === 'student' && effectiveInstitutionId) {
    const inst = await prisma.institution.findUnique({ where: { id: effectiveInstitutionId } });
    const code = generateInstCode(inst?.name);
    studentId = generateStudentId(code);
  }

  return prisma.$transaction(async (tx) => {
    const user = await tx.user.create({ data: { email, password_hash } });
    const profile = await tx.profile.create({
      data: {
        id: user.id,
        username: username.toLowerCase(),
        role,
        institution_id: effectiveInstitutionId,
        specialty: specialty || null,
        student_id: studentId,
      }
    });
    await tx.userRole.create({ data: { user_id: user.id, role } });
    await tx.creditTransaction.create({
      data: { user_id: user.id, delta: 100, type: 'grant', notes: 'Welcome bonus' }
    });
    await tx.userPrivate.create({ data: { user_id: user.id } });
    await tx.auditLog.create({
      data: {
        actor_id: actorId,
        action_type: 'member_created',
        target_table: 'profiles',
        target_id: profile.id,
        metadata: { role, username }
      }
    });
    return profile;
  });
}

async function createBulkMembers(actorId, institutionId, count, prefix, role) {
  const inst = await prisma.institution.findUnique({ where: { id: institutionId } });
  if (!inst) throw Object.assign(new Error('Institution not found'), { status: 404 });

  const code = generateInstCode(inst.name);
  const { uuidv4 } = require('../utils/helpers');
  const preparationTasks = [];

  for (let i = 1; i <= count; i++) {
    preparationTasks.push((async () => {
      const num = i.toString().padStart(4, '0');
      const randomSuffix = Math.random().toString(36).substring(2, 6);
      const username = `${prefix || 'user'}_${num}_${randomSuffix}`;
      const password = Math.random().toString(36).substring(2, 10);
      const email = `${username.toLowerCase()}@eternia.local`;
      const password_hash = await bcrypt.hash(password, 10);
      const baseStudentId = role === 'student' ? generateStudentId(code) : null;
      const studentId = baseStudentId ? `${baseStudentId}-${randomSuffix.toUpperCase()}` : null;
      const userId = uuidv4();
      return {
        user: { id: userId, email, password_hash },
        profile: { id: userId, username: username.toLowerCase(), role, institution_id: institutionId, student_id: studentId, is_active: true, is_verified: true },
        role: { user_id: userId, role },
        transaction: { user_id: userId, delta: 100, type: 'grant', notes: 'Welcome bonus' },
        private: { user_id: userId },
        result: { user_id: userId, username, password }
      };
    })());
  }

  const preparedData = await Promise.all(preparationTasks);

  try {
    await prisma.$transaction([
      prisma.user.createMany({ data: preparedData.map(d => d.user) }),
      prisma.profile.createMany({ data: preparedData.map(d => d.profile) }),
      prisma.userRole.createMany({ data: preparedData.map(d => d.role) }),
      prisma.creditTransaction.createMany({ data: preparedData.map(d => d.transaction) }),
      prisma.userPrivate.createMany({ data: preparedData.map(d => d.private) }),
    ]);
    await prisma.auditLog.create({
      data: {
        actor_id: actorId,
        action_type: 'bulk_members_created',
        target_table: 'institutions',
        target_id: institutionId,
        metadata: { count: preparedData.length, role }
      }
    });
    return { created_count: preparedData.length, members: preparedData.map(d => d.result) };
  } catch (err) {
    console.error('Failed to create bulk members:', err.message);
    throw Object.assign(new Error('Failed to create bulk members: ' + err.message), { status: 500 });
  }
}

async function deleteMember(actorId, actorRole, actorInstitutionId, memberId) {
  const member = await prisma.profile.findUnique({ where: { id: memberId } });
  if (!member) throw Object.assign(new Error('Member not found'), { status: 404 });

  if (actorRole === 'spoc' && member.institution_id !== actorInstitutionId) {
    throw Object.assign(new Error('Cannot delete members from other institutions'), { status: 403 });
  }
  if (member.role === 'admin') throw Object.assign(new Error('Cannot delete admin users'), { status: 403 });

  await prisma.user.delete({ where: { id: memberId } });
  await prisma.auditLog.create({
    data: {
      actor_id: actorId,
      action_type: 'member_deleted',
      target_table: 'profiles',
      target_id: memberId,
      metadata: { username: member.username, role: member.role }
    }
  });
  return { success: true };
}

async function toggleMemberStatus(actorId, memberId, activate) {
  const member = await prisma.profile.findUnique({ where: { id: memberId } });
  if (!member) throw Object.assign(new Error('Member not found'), { status: 404 });

  await prisma.profile.update({ where: { id: memberId }, data: { is_active: activate } });
  await prisma.auditLog.create({
    data: {
      actor_id: actorId,
      action_type: activate ? 'member_activated' : 'member_deactivated',
      target_table: 'profiles',
      target_id: memberId,
    }
  });
  return { success: true };
}

async function verifyMember(actorId, memberId, data) {
  const { is_verified, training_status, training_progress } = data;
  return prisma.profile.update({
    where: { id: memberId },
    data: {
      ...(is_verified !== undefined && { is_verified }),
      ...(training_status !== undefined && { training_status }),
      ...(training_progress !== undefined && { training_progress }),
    }
  });
}

async function getInstitutions() {
  return prisma.institution.findMany({ orderBy: { created_at: 'desc' } });
}

async function createInstitution(actorId, data) {
  const { name, eternia_code_hash, plan_type, credits_pool } = data;
  const crypto = require('crypto');
  const codeHash = eternia_code_hash || crypto.createHash('sha256').update(name + Date.now()).digest('hex');

  const inst = await prisma.institution.create({
    data: { name, eternia_code_hash: codeHash, plan_type: plan_type || 'basic', credits_pool: credits_pool || 0 }
  });
  await prisma.auditLog.create({
    data: { actor_id: actorId, action_type: 'institution_created', target_table: 'institutions', target_id: inst.id }
  });
  return inst;
}

async function createBulkTempIds(actorId, institutionId, count, prefix) {
  const crypto = require('crypto');
  const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
  const data = [];
  const results = [];
  for (let i = 0; i < count; i++) {
    const randomSuffix = crypto.randomBytes(3).toString('hex');
    const username = `${prefix || 'user'}_${randomSuffix}`;
    const password = crypto.randomBytes(4).toString('hex');
    data.push({ institution_id: institutionId, username, temp_password: password, expires_at: expiresAt });
    results.push({ username, password });
  }
  await prisma.tempCredential.createMany({ data });
  return { created_count: count, members: results };
}

async function getTempCredentials(institutionId) {
  return prisma.tempCredential.findMany({
    where: { institution_id: institutionId },
    orderBy: { created_at: 'desc' },
    take: 500
  });
}

async function deleteInstitution(actorId, institutionId) {
  await prisma.institution.delete({ where: { id: institutionId } });
  await prisma.auditLog.create({
    data: { actor_id: actorId, action_type: 'institution_deleted', target_table: 'institutions', target_id: institutionId }
  });
  return { success: true };
}

async function getAdminAppointments(limit = 50) {
  return prisma.appointment.findMany({
    include: {
      student: { select: { id: true, username: true } },
      expert: { select: { id: true, username: true, specialty: true } }
    },
    orderBy: { created_at: 'desc' },
    take: limit,
  });
}

async function getAdminPeerSessions(limit = 50) {
  return prisma.peerSession.findMany({
    include: {
      student: { select: { id: true, username: true } },
      intern: { select: { id: true, username: true } }
    },
    orderBy: { created_at: 'desc' },
    take: limit,
  });
}

async function getAdminBlackboxSessions(limit = 50) {
  return prisma.blackboxSession.findMany({
    include: { therapist: { select: { id: true, username: true } } },
    orderBy: { created_at: 'desc' },
    take: limit,
  });
}

async function getFlaggedEntries(limit = 20) {
  return prisma.blackboxEntry.findMany({
    where: { ai_flag_level: { gt: 0 } },
    orderBy: [{ ai_flag_level: 'desc' }, { created_at: 'desc' }],
    take: limit,
    include: { user: { select: { id: true, username: true } } }
  });
}

async function getEscalations(status) {
  const where = status ? { status } : {};
  return prisma.escalationRequest.findMany({
    where,
    include: {
      spoc: { select: { id: true, username: true } },
      admin: { select: { id: true, username: true } },
      entry: { select: { id: true, ai_flag_level: true } },
      session: { select: { id: true, status: true } }
    },
    orderBy: { created_at: 'desc' }
  });
}

async function updateEscalationStatus(actorId, escalationId, status) {
  if (!['approved', 'rejected', 'resolved'].includes(status)) {
    throw Object.assign(new Error('Invalid status'), { status: 400 });
  }
  return prisma.escalationRequest.update({
    where: { id: escalationId },
    data: { status, admin_id: actorId, resolved_at: new Date() }
  });
}

async function createEscalation(actorId, justification) {
  const escalation = await prisma.escalationRequest.create({
    data: { spoc_id: actorId, justification_encrypted: justification, status: 'pending' }
  });
  await prisma.auditLog.create({
    data: {
      actor_id: actorId,
      action_type: 'escalation_request_created',
      target_table: 'escalation_requests',
      target_id: escalation.id,
      metadata: { justification_length: justification.length }
    }
  });
  return escalation;
}

async function assignRole(actorId, profileId, role, institutionId) {
  const isExpertOrIntern = role === 'expert' || role === 'intern';
  return prisma.$transaction(async (tx) => {
    const profile = await tx.profile.update({
      where: { id: profileId },
      data: {
        role,
        is_active: true,
        is_verified: isExpertOrIntern ? true : undefined,
        institution_id: institutionId || undefined
      }
    });
    await tx.userRole.upsert({
      where: { user_id_role: { user_id: profileId, role } },
      update: {},
      create: { user_id: profileId, role }
    });
    await tx.auditLog.create({
      data: {
        actor_id: actorId,
        action_type: 'role_assigned',
        target_table: 'profiles',
        target_id: profileId,
        metadata: { role, username: profile.username }
      }
    });
    return profile;
  });
}

async function generateSpocQR(actorId, institutionId) {
  const crypto = require('crypto');
  const timestamp = Date.now();
  const payloadData = `${institutionId}:${actorId}:${timestamp}`;
  const signature = crypto.createHmac('sha256', process.env.JWT_SECRET || 'fallback_secret')
    .update(payloadData).digest('hex');
  const qr_payload = JSON.stringify({ institution_id: institutionId, spoc_id: actorId, timestamp, signature });
  return { qr_payload };
}

async function getAuditLogs(limit = 100) {
  return prisma.auditLog.findMany({
    include: { actor: { select: { id: true, username: true } } },
    orderBy: { created_at: 'desc' },
    take: limit,
  });
}

// ─── Training Modules ─────────────────────────────────────────────────────────

async function getTrainingModules() {
  return prisma.trainingModule.findMany({
    where: { is_active: true },
    orderBy: { day_number: 'asc' }
  });
}

async function upsertTrainingModule(data) {
  const { day_number, title, description, duration, objectives, content, has_quiz, quiz_questions, is_active } = data;
  return prisma.trainingModule.upsert({
    where: { day_number },
    update: { title, description, duration, objectives, content, has_quiz, quiz_questions, ...(is_active !== undefined && { is_active }) },
    create: { day_number, title, description, duration, objectives, content, has_quiz, quiz_questions }
  });
}

async function deleteTrainingModule(id) {
  return prisma.trainingModule.delete({ where: { id } });
}

// ─── Intern Referral Codes ────────────────────────────────────────────────────

async function getReferralCodes(actorRole, actorInstitutionId) {
  const where = {};
  if (actorRole === 'spoc' && actorInstitutionId) {
    where.institution_id = actorInstitutionId;
  }
  return prisma.internReferralCode.findMany({
    where,
    include: {
      institution: { select: { name: true } },
      user: { select: { username: true } }
    },
    orderBy: { created_at: 'desc' }
  });
}

async function createReferralCode(actorId, actorRole, actorInstitutionId, data) {
  const { institution_id, expires_at } = data;
  const crypto = require('crypto');
  const code = `REF-${crypto.randomBytes(4).toString('hex').toUpperCase()}`;
  const effectiveInstId = actorRole === 'spoc' ? actorInstitutionId : institution_id;
  return prisma.internReferralCode.create({
    data: {
      code,
      institution_id: effectiveInstId || null,
      expires_at: expires_at ? new Date(expires_at) : null
    }
  });
}

async function redeemReferralCode(actorId, code) {
  const referral = await prisma.internReferralCode.findUnique({ where: { code } });
  if (!referral) throw Object.assign(new Error('Invalid referral code'), { status: 404 });
  if (referral.is_used) throw Object.assign(new Error('Referral code already used'), { status: 400 });
  if (referral.expires_at && new Date(referral.expires_at) < new Date()) {
    throw Object.assign(new Error('Referral code expired'), { status: 400 });
  }

  return prisma.$transaction(async (tx) => {
    await tx.internReferralCode.update({
      where: { id: referral.id },
      data: { is_used: true, assigned_to: actorId, used_at: new Date() }
    });
    const profile = await tx.profile.update({
      where: { id: actorId },
      data: { training_status: 'active', is_verified: true, training_progress: [1, 2, 3, 4, 5, 6, 7] }
    });
    return { success: true, profile };
  });
}

// ─── Deletion Requests ────────────────────────────────────────────────────────

async function getDeletionRequests() {
  return prisma.notification.findMany({
    where: { type: 'deletion_request', is_read: false },
    orderBy: { created_at: 'desc' }
  });
}

async function approveDeletion(actorId, notificationId) {
  const notification = await prisma.notification.findUnique({ where: { id: notificationId } });
  if (!notification) throw Object.assign(new Error('Notification not found'), { status: 404 });

  const targetUserId = notification.metadata?.requesting_user_id;
  if (!targetUserId) throw Object.assign(new Error('Missing user ID in request'), { status: 400 });

  return prisma.$transaction(async (tx) => {
    await tx.user.delete({ where: { id: targetUserId } });
    await tx.notification.updateMany({
      where: { type: 'deletion_request', is_read: false },
      data: { is_read: true }
    });
    await tx.auditLog.create({
      data: {
        actor_id: actorId,
        action_type: 'account_deletion_approved',
        target_table: 'users',
        target_id: targetUserId,
        metadata: { notification_id: notificationId }
      }
    });
    return { success: true };
  });
}

async function rejectDeletion(actorId, notificationId) {
  const notification = await prisma.notification.findUnique({ where: { id: notificationId } });
  if (!notification) throw Object.assign(new Error('Notification not found'), { status: 404 });

  const targetUserId = notification.metadata?.requesting_user_id;
  await prisma.notification.update({ where: { id: notificationId }, data: { is_read: true } });

  if (targetUserId) {
    await prisma.notification.create({
      data: {
        user_id: targetUserId,
        type: 'deletion_rejected',
        title: 'Deletion Request Rejected',
        message: 'Your account deletion request has been reviewed and rejected by an administrator. Please contact support for more information.',
      }
    });
  }
  return { success: true };
}

async function getReports(institutionId, days) {
  const since = new Date();
  since.setDate(since.getDate() - parseInt(days || 30));

  let studentIds = [];
  if (institutionId) {
    const students = await prisma.profile.findMany({
      where: { institution_id: institutionId, role: 'student' },
      select: { id: true }
    });
    studentIds = students.map(s => s.id);
  }

  if (institutionId && studentIds.length === 0) {
    return { appointments: 0, peerSessions: 0, moodEntries: 0, questCompletions: 0 };
  }

  const whereClause = institutionId ? { in: studentIds } : undefined;

  const [appointments, peerSessions, moodEntries, questCompletions] = await Promise.all([
    prisma.appointment.count({ where: { student_id: whereClause, created_at: { gte: since } } }),
    prisma.peerSession.count({ where: { student_id: whereClause, created_at: { gte: since } } }),
    prisma.moodEntry.count({ where: { user_id: whereClause, created_at: { gte: since } } }),
    prisma.questCompletion.count({ where: { user_id: whereClause, completed_at: { gte: since } } })
  ]);

  return { appointments, peerSessions, moodEntries, questCompletions };
}

async function getEmergencyContact(studentId) {
  const userPrivate = await prisma.userPrivate.findUnique({
    where: { user_id: studentId }
  });
  if (!userPrivate) return null;
  return {
    name: userPrivate.emergency_name_encrypted || 'Not provided',
    phone: userPrivate.emergency_phone_encrypted || 'Not provided',
    relation: userPrivate.emergency_relation || 'Not specified',
    is_self: userPrivate.contact_is_self
  };
}

async function getPoolBalance(institutionId) {
  if (!institutionId) return 0;
  const pool = await prisma.eccStabilityPool.findUnique({
    where: { institution_id: institutionId }
  });
  return pool?.balance || 0;
}

module.exports = {
  getMembers, getStats, createMember, createBulkMembers, deleteMember, toggleMemberStatus, verifyMember,
  getInstitutions, createInstitution, deleteInstitution,
  createBulkTempIds, getTempCredentials,
  getAdminAppointments, getAdminPeerSessions, getAdminBlackboxSessions, getFlaggedEntries,
  getEscalations, updateEscalationStatus, createEscalation,
  assignRole, generateSpocQR, getAuditLogs,
  getTrainingModules, upsertTrainingModule, deleteTrainingModule,
  getReferralCodes, createReferralCode, redeemReferralCode,
  getDeletionRequests, approveDeletion, rejectDeletion,
  getReports, getEmergencyContact, getPoolBalance
};
