const { verifyToken } = require('../utils/jwt');
const prisma = require('../prisma/client');
const logger = require('../utils/logger');
const videosdkService = require('./videosdkService');

function initSocket(io) {
  // Authentication middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
      if (!token) {
        return next(new Error('Authentication token required'));
      }
      const cleanToken = token.startsWith('Bearer ') ? token.slice(7) : token;
      const decoded = verifyToken(cleanToken);

      const profile = await prisma.profile.findUnique({
        where: { id: decoded.userId },
        select: {
          id: true,
          username: true,
          role: true,
          institution_id: true,
          department: true,
          year: true,
          expertise_tags: true,
          availability_status: true,
          rating: true,
        }
      });

      if (!profile) {
        return next(new Error('User profile not found'));
      }

      socket.user = profile;
      next();
    } catch (err) {
      logger.error('Socket authentication failed:', err.message);
      next(new Error('Unauthorized'));
    }
  });

  io.on('connection', async (socket) => {
    const userId = socket.user.id;
    const userRole = socket.user.role;

    logger.info(`Socket connected: User ${userId} (${userRole}) with SocketID ${socket.id}`);

    // Join a room specific to this user ID for directed signaling
    socket.join(`user:${userId}`);

    // Update online status in DB
    try {
      // Default helpers to available, students to offline matchmaking presence
      const initialAvailability = userRole === 'student' ? 'offline' : 'available';
      const isAvailableBool = userRole !== 'student';

      await prisma.profile.update({
        where: { id: userId },
        data: {
          online_status: true,
          socket_id: socket.id,
          availability_status: initialAvailability
        }
      });

      await prisma.availabilityStatus.upsert({
        where: { user_id: userId },
        update: { is_available: isAvailableBool, last_seen: new Date() },
        create: { user_id: userId, is_available: isAvailableBool, last_seen: new Date() }
      });

      // Broadcast presence updates
      io.emit('user-online', { userId, role: userRole });
    } catch (err) {
      logger.error(`Error updating online status for user ${userId}:`, err.message);
    }

    // 1. Availability Toggles
    socket.on('availability-change', async (data) => {
      const { isAvailable } = data;
      try {
        const availability = isAvailable ? 'available' : 'busy';
        await prisma.profile.update({
          where: { id: userId },
          data: { availability_status: availability }
        });

        await prisma.availabilityStatus.upsert({
          where: { user_id: userId },
          update: { is_available: isAvailable, last_seen: new Date() },
          create: { user_id: userId, is_available: isAvailable, last_seen: new Date() }
        });

        io.emit('availability-change', { userId, isAvailable, role: userRole });
        logger.info(`User ${userId} availability changed to: ${availability}`);
      } catch (err) {
        logger.error(`Error changing availability for user ${userId}:`, err.message);
      }
    });

    // 2. Match Request (Student searching for assistance)
    socket.on('request-match', async (data) => {
      const { topic, targetRole } = data;
      logger.info(`Student ${userId} requested match for role: ${targetRole}, topic: ${topic}`);

      try {
        // Create match request entry
        const matchReq = await prisma.matchRequest.create({
          data: {
            student_id: userId,
            target_role: targetRole,
            topic: topic || 'General Help',
            status: 'pending'
          }
        });

        // Map targetRole to actual database AppRole
        const mappedRole = targetRole === 'peer' ? 'intern' : (targetRole === 'mentor' ? 'therapist' : 'expert');

        // Find available candidate matches
        const candidates = await prisma.profile.findMany({
          where: {
            role: mappedRole,
            online_status: true,
            availability_status: 'available',
            id: { not: userId }
          }
        });

        const studentProfile = socket.user;
        const scoredCandidates = candidates.map(c => {
          let score = 0;
          // Priority 1: Same Institution
          if (c.institution_id && c.institution_id === studentProfile.institution_id) {
            score += 1000;
          }
          // Priority 2: Same Department
          if (c.department && studentProfile.department && c.department.toLowerCase() === studentProfile.department.toLowerCase()) {
            score += 500;
          }
          // Priority 3: Matching Topic Tag
          if (topic && c.expertise_tags && c.expertise_tags.some(tag => tag.toLowerCase() === topic.toLowerCase())) {
            score += 250;
          }
          // Priority 4: Rating
          score += (c.rating || 5.0) * 10;

          return { profile: c, score };
        });

        // Sort descending by matchmaking score
        scoredCandidates.sort((a, b) => b.score - a.score);

        // Select top candidates to notify (up to 3 for fast Omegle/Discord style pick)
        const topCandidates = scoredCandidates.slice(0, 3).map(sc => sc.profile);

        if (topCandidates.length === 0) {
          socket.emit('match-failed', { reason: 'No matching online professionals available right now. Please try again later.' });
          await prisma.matchRequest.update({
            where: { id: matchReq.id },
            data: { status: 'cancelled' }
          });
          logger.info(`Match request ${matchReq.id} failed: No candidate found.`);
          return;
        }

        // Get institution name
        let institutionName = 'Eternia University';
        if (studentProfile.institution_id) {
          const inst = await prisma.institution.findUnique({
            where: { id: studentProfile.institution_id },
            select: { name: true }
          });
          if (inst) institutionName = inst.name;
        }

        const notificationPayload = {
          requestId: matchReq.id,
          studentId: userId,
          studentName: studentProfile.username || 'Anonymous Student',
          institution: institutionName,
          topic: topic || 'General Help',
          roleRequested: targetRole,
          createdAt: matchReq.created_at
        };

        // Notify top candidates and log notifications in DB
        for (const candidate of topCandidates) {
          if (candidate.socket_id) {
            io.to(candidate.socket_id).emit('request-created', notificationPayload);

            await prisma.matchNotification.create({
              data: {
                sender_id: userId,
                receiver_id: candidate.id,
                type: 'incoming_match',
                message: `Match request from student for topic: ${topic}`,
                status: 'unread'
              }
            });
            logger.info(`Sent request ${matchReq.id} to SocketID ${candidate.socket_id} (User: ${candidate.id})`);
          }
        }
      } catch (err) {
        logger.error(`Error initiating match request:`, err.message);
        socket.emit('match-failed', { reason: 'Internal matchmaking error' });
      }
    });

    // 3. Match Accept (Expert accepts the request)
    socket.on('accept-request', async (data) => {
      const { requestId } = data;
      logger.info(`User ${userId} attempting to accept request ${requestId}`);

      try {
        const request = await prisma.matchRequest.findUnique({
          where: { id: requestId }
        });

        if (!request) {
          socket.emit('request-expired', { message: 'Match request not found.' });
          return;
        }

        if (request.status !== 'pending') {
          socket.emit('request-expired', { message: 'This request has already been claimed or cancelled.' });
          return;
        }

        // Atomically transition the request state to accepted
        await prisma.matchRequest.update({
          where: { id: requestId },
          data: { status: 'accepted' }
        });

        // Initialize VideoSDK session room
        const videoSession = await videosdkService.createRoom();
        const meetingId = videoSession.roomId;
        const token = videoSession.token;

        // Save active session in DB
        const activeSession = await prisma.activeSession.create({
          data: {
            student_id: request.student_id,
            expert_id: userId,
            meeting_id: meetingId,
            session_type: 'video'
          }
        });

        // Update availability for both to busy
        await prisma.profile.updateMany({
          where: { id: { in: [request.student_id, userId] } },
          data: { availability_status: 'busy' }
        });

        await prisma.availabilityStatus.updateMany({
          where: { user_id: { in: [request.student_id, userId] } },
          data: { is_available: false, last_seen: new Date() }
        });

        io.emit('availability-change', { userId: request.student_id, isAvailable: false, role: 'student' });
        io.emit('availability-change', { userId: userId, isAvailable: false, role: userRole });

        // Build connection payload
        const sessionPayload = {
          sessionId: activeSession.id,
          meetingId: meetingId,
          token: token,
          studentId: request.student_id,
          expertId: userId,
          roleRequested: request.target_role
        };

        // Notify both parties to join session
        io.to(`user:${request.student_id}`).emit('session-started', sessionPayload);
        io.to(`user:${userId}`).emit('session-started', sessionPayload);

        // Cancel all pending calls across other candidates
        io.emit('request-cancelled', { requestId });
        logger.info(`Match established: Session ${activeSession.id} created for meeting ${meetingId}`);
      } catch (err) {
        logger.error(`Error accepting request ${requestId}:`, err.message);
        socket.emit('request-expired', { message: 'Unable to establish match. Please try again.' });
      }
    });

    // 4. Cancel Match (Student cancels request mid-search)
    socket.on('cancel-match', async (data) => {
      const { requestId } = data;
      logger.info(`Student ${userId} cancelled match request ${requestId}`);

      try {
        await prisma.matchRequest.update({
          where: { id: requestId },
          data: { status: 'cancelled' }
        });
        io.emit('request-cancelled', { requestId });
      } catch (err) {
        logger.error(`Error cancelling match request ${requestId}:`, err.message);
      }
    });

    // 5. Decline Request (Helper declines incoming card)
    socket.on('decline-request', async (data) => {
      const { requestId } = data;
      logger.info(`Helper ${userId} declined request ${requestId}`);

      try {
        const req = await prisma.matchRequest.findUnique({ where: { id: requestId } });
        if (req) {
          await prisma.matchNotification.updateMany({
            where: { receiver_id: userId, sender_id: req.student_id },
            data: { status: 'read' }
          });
        }
      } catch (err) {
        logger.error(`Error declining request:`, err.message);
      }
    });

    // 6. End Session (Either party leaves)
    socket.on('end-session', async (data) => {
      const { sessionId } = data;
      logger.info(`Session ${sessionId} ending triggered by user ${userId}`);

      try {
        const session = await prisma.activeSession.findUnique({
          where: { id: sessionId }
        });

        if (session) {
          const endedAt = new Date();
          await prisma.activeSession.update({
            where: { id: sessionId },
            data: { ended_at: endedAt }
          });

          const duration = Math.round((endedAt.getTime() - session.started_at.getTime()) / 1000);

          // Log session
          await prisma.sessionLog.create({
            data: {
              duration,
              participants: [session.student_id, session.expert_id],
              session_status: 'completed'
            }
          });

          // Reset availability status in DB
          // Student goes back offline/idle
          await prisma.profile.update({
            where: { id: session.student_id },
            data: { availability_status: 'offline' }
          });
          await prisma.availabilityStatus.update({
            where: { user_id: session.student_id },
            data: { is_available: false, last_seen: new Date() }
          });

          // Helper returns to available
          const helperProfile = await prisma.profile.findUnique({ where: { id: session.expert_id } });
          const helperRole = helperProfile ? helperProfile.role : 'expert';

          await prisma.profile.update({
            where: { id: session.expert_id },
            data: { availability_status: 'available' }
          });
          await prisma.availabilityStatus.update({
            where: { user_id: session.expert_id },
            data: { is_available: true, last_seen: new Date() }
          });

          // Notify clients
          io.to(`user:${session.student_id}`).emit('session-ended', { sessionId });
          io.to(`user:${session.expert_id}`).emit('session-ended', { sessionId });

          io.emit('availability-change', { userId: session.student_id, isAvailable: false, role: 'student' });
          io.emit('availability-change', { userId: session.expert_id, isAvailable: true, role: helperRole });

          logger.info(`Session ${sessionId} ended successfully. Duration: ${duration}s`);
        }
      } catch (err) {
        logger.error(`Error ending session ${sessionId}:`, err.message);
      }
    });

    // 7. Typing Indicators
    socket.on('typing', (data) => {
      const { recipientId, isTyping } = data;
      io.to(`user:${recipientId}`).emit('typing', { senderId: userId, isTyping });
    });

    // 8. Reconnect and State Restoration
    socket.on('reconnect-user', async () => {
      logger.info(`Attempting state reconnection for User ${userId}`);
      try {
        const active = await prisma.activeSession.findFirst({
          where: {
            OR: [
              { student_id: userId },
              { expert_id: userId }
            ],
            ended_at: null
          }
        });

        if (active) {
          const token = videosdkService.generateVideoSDKToken();

          // Re-update DB mapping to match current socket
          await prisma.profile.update({
            where: { id: userId },
            data: { socket_id: socket.id, online_status: true, availability_status: 'busy' }
          });

          socket.emit('session-restored', {
            sessionId: active.id,
            meetingId: active.meeting_id,
            token: token,
            studentId: active.student_id,
            expertId: active.expert_id
          });
          logger.info(`Restored active session ${active.id} for reconnecting user ${userId}`);
        } else {
          socket.emit('session-restored', null);
        }
      } catch (err) {
        logger.error(`Error reconnecting state:`, err.message);
      }
    });

    // Clean disconnect handling
    socket.on('disconnect', async () => {
      logger.info(`Socket disconnected: SocketID ${socket.id} (User: ${userId})`);
      try {
        await prisma.profile.update({
          where: { id: userId },
          data: { online_status: false, socket_id: null, availability_status: 'offline' }
        });

        await prisma.availabilityStatus.update({
          where: { user_id: userId },
          data: { is_available: false, last_seen: new Date() }
        });

        io.emit('user-offline', { userId });
      } catch (err) {
        logger.error(`Error cleaning up disconnect for user ${userId}:`, err.message);
      }
    });
  });
}

module.exports = { initSocket };
