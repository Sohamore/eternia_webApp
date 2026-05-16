const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/appointmentsController');
const { authenticate, requireRole } = require('../middlewares/auth');
const { generalLimiter } = require('../middlewares/rateLimit');

router.get('/experts', authenticate, ctrl.getExperts);
router.get('/slots', authenticate, ctrl.getSlots);
router.get('/my-slots', authenticate, requireRole('expert'), ctrl.getMySlots);
router.get('/', authenticate, ctrl.getMyAppointments);
router.post('/', authenticate, generalLimiter, ctrl.createAppointment);
router.patch('/:id/cancel', authenticate, ctrl.cancelAppointment);
router.post('/slots', authenticate, requireRole('expert'), ctrl.addSlot);
router.delete('/slots/:id', authenticate, requireRole('expert'), ctrl.deleteSlot);
router.patch('/:id/complete', authenticate, requireRole('expert'), ctrl.completeAppointment);
router.patch('/:id/reschedule', authenticate, requireRole('expert'), ctrl.rescheduleAppointment);
router.post('/:id/escalate', authenticate, requireRole('expert'), ctrl.escalateAppointment);

module.exports = router;
