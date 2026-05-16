const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/soundController');
const { authenticate, requireRole } = require('../middlewares/auth');
const { generalLimiter } = require('../middlewares/rateLimit');

const isAdminOrSpoc = requireRole('admin', 'spoc');

router.get('/', authenticate, ctrl.getSounds);
router.get('/admin/all', authenticate, isAdminOrSpoc, ctrl.getAllSoundsAdmin);
router.post('/', authenticate, isAdminOrSpoc, generalLimiter, ctrl.createSound);
router.patch('/:id', authenticate, isAdminOrSpoc, ctrl.updateSound);
router.delete('/:id', authenticate, isAdminOrSpoc, ctrl.deleteSound);

module.exports = router;
