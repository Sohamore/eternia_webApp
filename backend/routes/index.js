const express = require('express');
const router = express.Router();

router.use('/auth', require('./auth'));
router.use('/credits', require('./credits'));
router.use('/appointments', require('./appointments'));
router.use('/blackbox', require('./blackbox'));
router.use('/peers', require('./peers'));
router.use('/admin', require('./admin'));
router.use('/quests', require('./quests'));
router.use('/sound', require('./sound'));
router.use('/notifications', require('./notifications'));
router.use('/analytics', require('./analytics'));
router.use('/institutions', require('./institutions'));
router.use('/videosdk', require('./videosdk'));
router.use('/selfhelp', require('./selfhelp'));
router.use('/profiles', require('./profiles'));

module.exports = router;
