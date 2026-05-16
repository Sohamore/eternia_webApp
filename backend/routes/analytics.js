const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/analyticsController');
const { optionalAuth, authenticate, requireRole } = require('../middlewares/auth');
const { generalLimiter } = require('../middlewares/rateLimit');

router.post('/events', optionalAuth, generalLimiter, ctrl.trackEvent);
router.get('/data', authenticate, requireRole('admin'), ctrl.getAnalyticsData);

module.exports = router;
