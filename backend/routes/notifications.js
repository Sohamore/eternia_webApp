const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/notificationsController');
const { authenticate } = require('../middlewares/auth');

router.get('/', authenticate, ctrl.getNotifications);
router.patch('/:id/read', authenticate, ctrl.markAsRead);
router.patch('/read-all', authenticate, ctrl.markAllAsRead);

module.exports = router;
