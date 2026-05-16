const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/profilesController');
const { authenticate } = require('../middlewares/auth');
const { generalLimiter } = require('../middlewares/rateLimit');

router.get('/me', authenticate, ctrl.getMyProfile);
router.get('/me/private', authenticate, ctrl.getMyPrivateData);
router.patch('/me', authenticate, generalLimiter, ctrl.updateMyProfile);
router.post('/verify-student-id', ctrl.verifyStudentId);
router.post('/recovery', authenticate, ctrl.setRecoveryCredentials);
router.patch('/emergency-contact', authenticate, ctrl.updateEmergencyContact);
router.get('/emergency-contact/:userId', authenticate, ctrl.getEmergencyContact);
router.get('/:id', authenticate, ctrl.getProfileById);
router.post('/validate-spoc-qr', ctrl.validateSpocQR);
router.post('/me/redeem-referral', authenticate, ctrl.redeemReferral);
router.get('/training-modules', authenticate, ctrl.getTrainingModules);

module.exports = router;
