const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/videosdkController');
const { authenticate } = require('../middlewares/auth');
const { strictLimiter } = require('../middlewares/rateLimit');

router.post('/token', authenticate, strictLimiter, ctrl.getToken);
router.post('/room', authenticate, strictLimiter, ctrl.createRoom);

module.exports = router;
