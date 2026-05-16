const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/peersController');
const { authenticate } = require('../middlewares/auth');
const { generalLimiter } = require('../middlewares/rateLimit');

router.get('/interns', authenticate, ctrl.getInterns);
router.get('/sessions/active', authenticate, ctrl.getActiveSessions);
router.get('/sessions', authenticate, ctrl.getMySessions);
router.post('/sessions', authenticate, generalLimiter, ctrl.requestSession);
router.patch('/sessions/:id/accept', authenticate, ctrl.acceptSession);
router.patch('/sessions/:id/decline', authenticate, ctrl.declineSession);
router.patch('/sessions/:id/end', authenticate, ctrl.endSession);
router.patch('/sessions/:id/flag', authenticate, ctrl.flagSession);
router.get('/sessions/:id/messages', authenticate, ctrl.getMessages);
router.post('/sessions/:id/messages', authenticate, generalLimiter, ctrl.sendMessage);
router.patch('/sessions/:id/start-call', authenticate, ctrl.startCall);

module.exports = router;
