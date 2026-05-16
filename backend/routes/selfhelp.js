const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/selfhelpController');
const { authenticate } = require('../middlewares/auth');
const { generalLimiter } = require('../middlewares/rateLimit');

router.get('/gratitude', authenticate, ctrl.getGratitude);
router.post('/gratitude', authenticate, generalLimiter, ctrl.addGratitude);
router.get('/journal', authenticate, ctrl.getJournal);
router.post('/journal', authenticate, generalLimiter, ctrl.addJournalEntry);
router.delete('/journal/:id', authenticate, ctrl.deleteJournalEntry);
router.get('/mood', authenticate, ctrl.getMood);
router.post('/mood', authenticate, generalLimiter, ctrl.addMoodEntry);

module.exports = router;
