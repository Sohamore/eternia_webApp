const express = require("express");
const router = express.Router();
const ctrl = require("../controllers/authController");
const { authenticate } = require("../middlewares/auth");
const { authLimiter } = require("../middlewares/rateLimit");
console.log("server started");
router.post("/register", authLimiter, ctrl.register);
router.post("/login", authLimiter, ctrl.login);
router.post("/refresh", authLimiter, ctrl.refresh);
router.post("/logout", authenticate, ctrl.logout);
router.get("/me", authenticate, ctrl.me);
router.post("/activate-account", authLimiter, ctrl.activateAccount);
router.post("/get-recovery-hints", authLimiter, ctrl.getRecoveryHints);
router.post("/recover-password", authLimiter, ctrl.recoverPassword);
router.post("/verify-institutional-code", authLimiter, ctrl.verifyInstitutionalCode);

// OTP Simulation Routes
router.post("/send-otp", authLimiter, ctrl.sendOTP);
router.post("/verify-otp", authLimiter, ctrl.verifyOTP);
router.post("/reset-password-otp", authLimiter, ctrl.resetPasswordOTP);
router.post("/verify-temp-credentials", authLimiter, ctrl.verifyTempCredentials);
router.post("/reset-password-direct", authLimiter, ctrl.resetPasswordDirect);

module.exports = router;
