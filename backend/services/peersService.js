const prisma = require('../prisma/client');
const logger = require('../utils/logger');

const PEER_COST_ECC = 18;
const PENDING_EXPIRY_MS = 2 * 60 * 1000;

async function getInterns(excludeUserId) {
  const interns = await prisma.profile.findMany({
    where: { role: 'intern', is_active: true },
    select: { id: true, username: true, specialty: true, is_active: true, training_status: true }
  });
  return interns.filter((i) => i.id !== excludeUserId);
}

async function getActivePeerSessions() {
  return prisma.peerSession.findMany({
    where: { status: { in: ['active', 'pending'] } },
    select: { intern_id: true }
  });
}

async function getUserSessions(userId, role) {
  const isIntern = role === 'intern';
  const where = isIntern
    ? { OR: [{ intern_id: userId }, { student_id: userId }] }
    : { student_id: userId };

  return prisma.peerSession.findMany({
    where,
    include: {
      intern: { select: { id: true, username: true, specialty: true, is_active: true, training_status: true } },
      student: { select: { id: true, username: true, specialty: true, role: true } }
    },
    orderBy: { created_at: 'desc' },
    take: 20,
  });
}

async function requestSession(studentId, internId) {
  // Check for existing fresh session
  const existing = await prisma.peerSession.findFirst({
    where: {
      student_id: studentId,
      intern_id: internId,
      status: 'pending',
      created_at: { gt: new Date(Date.now() - PENDING_EXPIRY_MS) }
    }
  });
  if (existing) return { session: existing, existing: true };

  // Check intern is not busy
  const busy = await prisma.peerSession.findFirst({
    where: { intern_id: internId, status: { in: ['active', 'pending'] } }
  });
  if (busy) throw Object.assign(new Error('Intern is currently busy'), { status: 409 });

  const session = await prisma.peerSession.create({
    data: { student_id: studentId, intern_id: internId, status: 'pending' },
    include: {
      intern: { select: { id: true, username: true, specialty: true } },
      student: { select: { id: true, username: true } }
    }
  });

  // Notify intern
  await prisma.notification.create({
    data: {
      user_id: internId,
      type: 'peer_request',
      title: 'New Peer Session Request',
      message: `A student is requesting a peer support session`,
      metadata: { session_id: session.id }
    }
  });

  return { session, existing: false };
}

async function acceptSession(internId, sessionId) {
  const session = await prisma.peerSession.findFirst({
    where: { id: sessionId, intern_id: internId, status: 'pending' }
  });
  if (!session) throw Object.assign(new Error('Session not found or not pending'), { status: 404 });

  const updated = await prisma.peerSession.update({
    where: { id: sessionId },
    data: { status: 'active', started_at: new Date() },
    include: {
      student: { select: { id: true, username: true } },
      intern: { select: { id: true, username: true } }
    }
  });

  // Notify student
  await prisma.notification.create({
    data: {
      user_id: session.student_id,
      type: 'peer_accepted',
      title: 'Session Accepted',
      message: 'Your peer support session has been accepted',
      metadata: { session_id: sessionId }
    }
  });

  return { session: updated };
}

async function declineSession(internId, sessionId) {
  const session = await prisma.peerSession.findFirst({
    where: { id: sessionId, intern_id: internId, status: 'pending' }
  });
  if (!session) throw Object.assign(new Error('Session not found'), { status: 404 });

  await prisma.peerSession.update({
    where: { id: sessionId },
    data: { status: 'completed', ended_at: new Date() }
  });

  await prisma.notification.create({
    data: {
      user_id: session.student_id,
      type: 'peer_declined',
      title: 'Session Declined',
      message: 'The intern is not available at this time',
      metadata: { session_id: sessionId }
    }
  });

  return { success: true };
}

async function endSession(userId, sessionId) {
  const session = await prisma.peerSession.findFirst({
    where: {
      id: sessionId,
      OR: [{ student_id: userId }, { intern_id: userId }]
    }
  });
  if (!session) throw Object.assign(new Error('Session not found'), { status: 404 });

  await prisma.peerSession.update({
    where: { id: sessionId },
    data: { status: 'completed', ended_at: new Date() }
  });

  return { success: true };
}

async function flagSession(internId, sessionId, escalationNote, justification) {
  const session = await prisma.peerSession.findFirst({
    where: { id: sessionId, intern_id: internId }
  });
  if (!session) throw Object.assign(new Error('Session not found'), { status: 404 });

  await prisma.peerSession.update({
    where: { id: sessionId },
    data: { is_flagged: true, escalation_note_encrypted: escalationNote || null }
  });

  // Find SPOC for student's institution
  const studentProfile = await prisma.profile.findUnique({
    where: { id: session.student_id },
    select: { institution_id: true, username: true }
  });

  if (studentProfile?.institution_id) {
    const spoc = await prisma.profile.findFirst({
      where: { institution_id: studentProfile.institution_id, role: 'spoc', is_active: true }
    });

    if (spoc) {
      const escalation = await prisma.escalationRequest.create({
        data: {
          session_id: sessionId,
          spoc_id: spoc.id,
          justification_encrypted: justification || escalationNote || 'Session flagged for review',
          escalation_level: 1,
          trigger_timestamp: new Date(),
        }
      });

      await prisma.notification.create({
        data: {
          user_id: spoc.id,
          type: 'escalation',
          title: 'Session Flagged',
          message: `A peer session has been flagged for review`,
          metadata: { session_id: sessionId, escalation_id: escalation.id }
        }
      });

      await prisma.auditLog.create({
        data: {
          actor_id: internId,
          action_type: 'session_flagged',
          target_table: 'peer_sessions',
          target_id: sessionId,
          metadata: { student_id: session.student_id, spoc_id: spoc.id }
        }
      });
    }
  }

  // Fetch student's emergency contact
  const userPrivate = await prisma.userPrivate.findUnique({
    where: { user_id: session.student_id }
  });

  let contact = null;
  if (userPrivate && userPrivate.emergency_name_encrypted) {
    contact = {
      name: userPrivate.emergency_name_encrypted,
      phone: userPrivate.emergency_phone_encrypted
    };
  }

  return { success: true, contact };
}

async function getMessages(userId, sessionId, cursor, limit = 50) {
  // Verify user is participant
  const session = await prisma.peerSession.findFirst({
    where: {
      id: sessionId,
      OR: [{ student_id: userId }, { intern_id: userId }]
    }
  });
  if (!session) throw Object.assign(new Error('Session not found'), { status: 404 });

  const where = { session_id: sessionId };
  if (cursor) where.created_at = { lt: new Date(cursor) };

  const messages = await prisma.peerMessage.findMany({
    where,
    orderBy: { created_at: 'desc' },
    take: limit + 1,
  });

  const hasMore = messages.length > limit;
  return { messages: hasMore ? messages.slice(0, limit) : messages, hasMore };
}

async function sendMessage(userId, sessionId, content) {
  // Verify user is participant
  const session = await prisma.peerSession.findFirst({
    where: {
      id: sessionId,
      OR: [{ student_id: userId }, { intern_id: userId }],
      status: 'active'
    }
  });
  if (!session) throw Object.assign(new Error('Active session not found'), { status: 404 });

  return prisma.peerMessage.create({
    data: { session_id: sessionId, sender_id: userId, content_encrypted: content }
  });
}

async function startCall(userId, sessionId) {
  const session = await prisma.peerSession.findFirst({
    where: {
      id: sessionId,
      OR: [{ student_id: userId }, { intern_id: userId }],
      status: 'active'
    }
  });
  if (!session) throw Object.assign(new Error('Session not found'), { status: 404 });

  // Idempotent - only set room_id if not already set
  if (session.room_id) return { session, room_id: session.room_id };

  const { uuidv4 } = require('../utils/helpers');
  const room_id = uuidv4();

  const updated = await prisma.peerSession.update({
    where: { id: sessionId },
    data: { room_id }
  });

  // System message
  await prisma.peerMessage.create({
    data: {
      session_id: sessionId,
      sender_id: userId,
      content_encrypted: '📞 Voice call started'
    }
  });

  // Notify other party
  const otherId = session.student_id === userId ? session.intern_id : session.student_id;
  if (otherId) {
    await prisma.notification.create({
      data: {
        user_id: otherId,
        type: 'peer_call',
        title: 'Incoming Call',
        message: 'Your peer is starting a voice call',
        metadata: { session_id: sessionId, room_id }
      }
    });
  }

  return { session: updated, room_id };
}

module.exports = {
  getInterns, getActivePeerSessions, getUserSessions,
  requestSession, acceptSession, declineSession, endSession,
  flagSession, getMessages, sendMessage, startCall
};
