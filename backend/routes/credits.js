const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/creditsController');
const { authenticate, requireRole } = require('../middlewares/auth');
const { creditsLimiter, strictLimiter } = require('../middlewares/rateLimit');

router.get('/balance', authenticate, ctrl.getBalance);
router.get('/weekly-earn-total', authenticate, ctrl.getWeeklyEarnTotal);
router.get('/transactions', authenticate, ctrl.getTransactions);
router.post('/earn', authenticate, creditsLimiter, ctrl.earnCredits);
router.post('/spend', authenticate, creditsLimiter, ctrl.spendCredits);
router.post('/grant', authenticate, requireRole('admin', 'spoc'), creditsLimiter, ctrl.grantCredits);
router.post('/purchase/create-order', authenticate, strictLimiter, ctrl.createOrder);
router.post('/purchase/verify-payment', authenticate, strictLimiter, ctrl.verifyPayment);

module.exports = router;
