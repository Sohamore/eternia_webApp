const blackboxService = require('../services/blackboxService');

// Entries
async function getEntries(req, res, next) {
  try {
    const { cursor, limit } = req.query;
    const result = await blackboxService.getEntries(req.user.id, cursor, parseInt(limit) || 30);
    res.json(result);
  } catch (err) { next(err); }
}

async function createEntry(req, res, next) {
  try {
    const { content, content_type, is_private } = req.body;
    if (!content) return res.status(400).json({ error: 'Content required' });
    const entry = await blackboxService.createEntry(req.user.id, content, content_type, is_private);
    res.status(201).json({ entry });
  } catch (err) { next(err); }
}

async function deleteEntry(req, res, next) {
  try {
    const result = await blackboxService.deleteEntry(req.user.id, req.params.id);
    res.json(result);
  } catch (err) { next(err); }
}

async function moderateEntry(req, res, next) {
  try {
    const result = await blackboxService.moderateEntry(req.user.id, req.params.id);
    res.json(result);
  } catch (err) { next(err); }
}

// Sessions
async function getDailyCount(req, res, next) {
  try {
    const count = await blackboxService.getDailyCount(req.user.id);
    res.json({ count });
  } catch (err) { next(err); }
}

async function getUsageCount(req, res, next) {
  try {
    const count = await blackboxService.getUsageCount(req.user.id);
    res.json({ count });
  } catch (err) { next(err); }
}

async function getActiveSessions(req, res, next) {
  try {
    const sessions = await blackboxService.getActiveSessions(req.user.id);
    res.json({ sessions });
  } catch (err) { next(err); }
}

async function getSessionById(req, res, next) {
  try {
    const session = await blackboxService.getSessionById(req.params.id);
    if (!session) return res.status(404).json({ error: 'Session not found' });
    res.json({ session });
  } catch (err) { next(err); }
}

async function createSession(req, res, next) {
  try {
    const result = await blackboxService.createSession(req.user.id);
    res.status(result.reconnected ? 200 : 201).json(result);
  } catch (err) { next(err); }
}

async function cancelSession(req, res, next) {
  try {
    const result = await blackboxService.cancelSession(req.user.id, req.params.id);
    res.json(result);
  } catch (err) { next(err); }
}

async function endSession(req, res, next) {
  try {
    const result = await blackboxService.endSession(req.params.id, req.user.id);
    res.json(result);
  } catch (err) { next(err); }
}

async function joinSession(req, res, next) {
  try {
    const result = await blackboxService.updateSessionJoin(req.params.id, req.user.id);
    res.json(result);
  } catch (err) { next(err); }
}

// Therapist endpoints
async function getTherapistQueue(req, res, next) {
  try {
    const queue = await blackboxService.getTherapistQueue();
    res.json({ queue });
  } catch (err) { next(err); }
}

async function getTherapistActive(req, res, next) {
  try {
    const sessions = await blackboxService.getTherapistActive(req.user.id);
    res.json({ sessions });
  } catch (err) { next(err); }
}

async function getTherapistHistory(req, res, next) {
  try {
    const history = await blackboxService.getTherapistHistory(req.user.id);
    res.json({ history });
  } catch (err) { next(err); }
}

async function acceptSession(req, res, next) {
  try {
    const { room_id } = req.body;
    const session = await blackboxService.acceptSessionByTherapist(req.params.id, req.user.id, room_id);
    res.json({ session });
  } catch (err) { next(err); }
}

async function escalateSession(req, res, next) {
  try {
    const { level, reason } = req.body;
    const session = await blackboxService.escalateSessionByTherapist(req.params.id, req.user.id, level, reason);
    res.json({ session });
  } catch (err) { next(err); }
}

async function saveNotes(req, res, next) {
  try {
    const { session_notes_encrypted } = req.body;
    const session = await blackboxService.saveSessionNotes(req.params.id, req.user.id, session_notes_encrypted);
    res.json({ session });
  } catch (err) { next(err); }
}

async function therapistJoinSession(req, res, next) {
  try {
    const result = await blackboxService.updateTherapistJoin(req.params.id, req.user.id);
    res.json(result);
  } catch (err) { next(err); }
}

module.exports = {
  getEntries, createEntry, deleteEntry, moderateEntry,
  getDailyCount, getUsageCount, getActiveSessions, getSessionById,
  createSession, cancelSession, endSession, joinSession,
  getTherapistQueue, getTherapistActive, getTherapistHistory,
  acceptSession, escalateSession, saveNotes, therapistJoinSession
};
