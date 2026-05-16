const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/institutionsController');
const { authenticate, optionalAuth } = require('../middlewares/auth');

router.get('/', authenticate, ctrl.getInstitutions);
router.get('/:id', authenticate, ctrl.getInstitutionById);
router.post('/verify-code', ctrl.verifyCode);

module.exports = router;
