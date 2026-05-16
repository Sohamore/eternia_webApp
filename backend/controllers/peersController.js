const peersService = require('../services/peersService');

async function getInterns(req, res, next) {
  try {
    const interns = await peersService.getInterns(req.user.id);
    res.json({ interns });
  } catch (err) { next(err); }
}

async function getActiveSessions(req, res, next) {
  try {
    const sessions = await peersService.getActivePeerSessions();
    res.json({ sessions });
  } catch (err) { next(err); }
}

async function getMySessions(req, res, next) {
  try {
    const sessions = await peersService.getUserSessions(req.user.id, req.user.role);
    res.json({ sessions });
  } catch (err) { next(err); }
}

async function requestSession(req, res, next) {
  try {
    const { intern_id } = req.body;
    if (!intern_id) return res.status(400).json({ error: 'intern_id required' });
    const result = await peersService.requestSession(req.user.id, intern_id);
    res.status(result.existing ? 200 : 201).json(result);
  } catch (err) { next(err); }
}

async function acceptSession(req, res, next) {
  try {
    const result = await peersService.acceptSession(req.user.id, req.params.id);
    res.json(result);
  } catch (err) { next(err); }
}

async function declineSession(req, res, next) {
  try {
    const result = await peersService.declineSession(req.user.id, req.params.id);
    res.json(result);
  } catch (err) { next(err); }
}

async function endSession(req, res, next) {
  try {
    const result = await peersService.endSession(req.user.id, req.params.id);
    res.json(result);
  } catch (err) { next(err); }
}

async function flagSession(req, res, next) {
  try {
    const { escalation_note, justification } = req.body;
    const result = await peersService.flagSession(req.user.id, req.params.id, escalation_note, justification);
    res.json(result);
  } catch (err) { next(err); }
}

async function getMessages(req, res, next) {
  try {
    const { cursor, limit } = req.query;
    const result = await peersService.getMessages(req.user.id, req.params.id, cursor, parseInt(limit) || 50);
    res.json(result);
  } catch (err) { next(err); }
}

async function sendMessage(req, res, next) {
  try {
    const { content } = req.body;
    if (!content) return res.status(400).json({ error: 'Content required' });
    const message = await peersService.sendMessage(req.user.id, req.params.id, content);
    res.status(201).json({ message });
  } catch (err) { next(err); }
}

async function startCall(req, res, next) {
  try {
    const result = await peersService.startCall(req.user.id, req.params.id);
    res.json(result);
  } catch (err) { next(err); }
}

module.exports = {
  getInterns, getActiveSessions, getMySessions, requestSession,
  acceptSession, declineSession, endSession, flagSession,
  getMessages, sendMessage, startCall
};
