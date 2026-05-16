const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/blackboxController');
const { authenticate } = require('../middlewares/auth');
const { aiLimiter, generalLimiter } = require('../middlewares/rateLimit');

// Entries
router.get('/entries', authenticate, ctrl.getEntries);
router.post('/entries', authenticate, generalLimiter, ctrl.createEntry);
router.delete('/entries/:id', authenticate, ctrl.deleteEntry);
router.post('/entries/:id/moderate', authenticate, aiLimiter, ctrl.moderateEntry);

// Sessions
router.get('/sessions/active', authenticate, ctrl.getActiveSessions);
router.get('/sessions/:id', authenticate, ctrl.getSessionById);
router.post('/sessions', authenticate, generalLimiter, ctrl.createSession);
router.patch('/sessions/:id/cancel', authenticate, ctrl.cancelSession);
router.patch('/sessions/:id/end', authenticate, ctrl.endSession);
router.patch('/sessions/:id/join', authenticate, ctrl.joinSession);
router.get('/daily-count', authenticate, ctrl.getDailyCount);
router.get('/usage-count', authenticate, ctrl.getUsageCount);

// Therapist/Expert
router.get('/therapist/queue', authenticate, ctrl.getTherapistQueue);
router.get('/therapist/active', authenticate, ctrl.getTherapistActive);
router.get('/therapist/history', authenticate, ctrl.getTherapistHistory);
router.patch('/therapist/sessions/:id/accept', authenticate, ctrl.acceptSession);
router.patch('/therapist/sessions/:id/escalate', authenticate, ctrl.escalateSession);
router.patch('/therapist/sessions/:id/notes', authenticate, ctrl.saveNotes);
router.patch('/therapist/sessions/:id/join', authenticate, ctrl.therapistJoinSession);

module.exports = router;
