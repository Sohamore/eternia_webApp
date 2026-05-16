const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/questsController');
const { authenticate, requireRole } = require('../middlewares/auth');
const { generalLimiter } = require('../middlewares/rateLimit');

const isAdminOrSpoc = requireRole('admin', 'spoc');

// User endpoints
router.get('/', authenticate, ctrl.getQuests);
router.get('/completions/today', authenticate, ctrl.getTodayCompletions);
router.post('/complete', authenticate, generalLimiter, ctrl.completeQuest);

// Admin endpoints
router.get('/admin/all', authenticate, isAdminOrSpoc, ctrl.getAllQuestsAdmin);
router.get('/admin/completions', authenticate, isAdminOrSpoc, ctrl.getAllCompletionsAdmin);
router.post('/admin', authenticate, isAdminOrSpoc, generalLimiter, ctrl.createQuest);
router.patch('/admin/:id', authenticate, isAdminOrSpoc, ctrl.updateQuest);
router.delete('/admin/:id', authenticate, isAdminOrSpoc, ctrl.deleteQuest);

module.exports = router;
