const authService = require("../services/authService");
const logger = require("../utils/logger");

async function register(req, res, next) {
  try {
    const { username, password, ...metadata } = req.body;
    if (!username || !password)
      return res.status(400).json({ error: "Username and password required" });
    if (password.length < 8)
      return res
        .status(400)
        .json({ error: "Password must be at least 8 characters" });
    const result = await authService.registerUser(username, password, metadata);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
}

async function login(req, res, next) {
  const { username, password } = req.body;
  console.log(`[Auth] Login attempt for username: ${username}`);
  try {
    if (!username || !password)
      return res.status(400).json({ error: "Username and password required" });
    const result = await authService.loginUser(username, password);
    console.log(`[Auth] Login successful for: ${username}`);
    res.json(result);
  } catch (err) {
    next(err);
  }
}

async function refresh(req, res, next) {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken)
      return res.status(400).json({ error: "Refresh token required" });
    const result = await authService.refreshUserToken(refreshToken);
    res.json(result);
  } catch (err) {
    next(err);
  }
}

async function me(req, res, next) {
  try {
    const result = await authService.getCurrentUser(req.user.id);
    res.json(result);
  } catch (err) {
    next(err);
  }
}

async function logout(req, res) {
  res.json({ success: true });
}

async function activateAccount(req, res, next) {
  try {
    const {
      tempCredentialId,
      username,
      password,
      emergencyContact,
      studentIdData,
    } = req.body;
    if (!tempCredentialId || !username || !password) {
      return res
        .status(400)
        .json({ error: "tempCredentialId, username, and password required" });
    }
    const result = await authService.activateAccount(
      tempCredentialId,
      username,
      password,
      emergencyContact,
      studentIdData,
    );
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
}

async function getRecoveryHints(req, res, next) {
  try {
    const { username } = req.body;
    if (!username) return res.status(400).json({ error: "Username required" });
    const result = await authService.getRecoveryHints(username);
    res.json(result);
  } catch (err) {
    next(err);
  }
}

async function recoverPassword(req, res, next) {
  try {
    const { username, fragmentPairs, emojiPattern, newPassword } = req.body;
    if (!username || !fragmentPairs || !emojiPattern || !newPassword) {
      return res.status(400).json({ error: "All recovery fields required" });
    }
    const { userId } = await authService.recoverPassword(
      username,
      fragmentPairs,
      emojiPattern,
    );
    await authService.updatePassword(userId, newPassword);
    res.json({ success: true, message: "Password updated successfully" });
  } catch (err) {
    next(err);
  }
}

async function verifyInstitutionalCode(req, res, next) {
  try {
    const { code } = req.body;
    if (!code) return res.status(400).json({ error: "Code required" });
    const result = await authService.verifyInstitutionalCode(code);
    res.json(result);
  } catch (err) {
    next(err);
  }
}

const { sendEmail } = require("../utils/emailService");
const prisma = require("../prisma/client");
const crypto = require("crypto");

// REAL OTP FLOW
async function sendOTP(req, res, next) {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ error: "Email/Username required" });
    
    // Generate 4-digit code
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Store in DB
    await prisma.verificationCode.create({
      data: {
        email: email.toLowerCase(),
        code: otp,
        expires_at: expiresAt,
      }
    });

    console.log(`[REAL OTP] for ${email} is: ${otp}`);
    
    // Send email (structure is ready, currently logs to console)
    await sendEmail(
      email, 
      "Eternia Password Reset Code", 
      `Your verification code is: ${otp}. It expires in 10 minutes.`,
      `<h3>Verification Code</h3><p>Your code is: <b>${otp}</b></p><p>Valid for 10 minutes.</p>`
    );
    
    res.json({ success: true, message: "Verification code sent to your email" });
  } catch (err) { next(err); }
}

async function verifyOTP(req, res, next) {
  try {
    const { email, otp } = req.body;
    if (!email || !otp) return res.status(400).json({ error: "Email and OTP required" });
    
    const record = await prisma.verificationCode.findFirst({
      where: {
        email: email.toLowerCase(),
        code: otp,
        expires_at: { gt: new Date() }
      },
      orderBy: { created_at: 'desc' }
    });

    if (record) {
      res.json({ success: true, message: "OTP Verified" });
    } else {
      res.status(400).json({ error: "Invalid or expired OTP" });
    }
  } catch (err) { next(err); }
}

async function resetPasswordOTP(req, res, next) {
  try {
    const { username, newPassword, otp } = req.body;
    if (!username || !newPassword || !otp) {
      return res.status(400).json({ error: "All fields required" });
    }

    // Double check OTP
    const record = await prisma.verificationCode.findFirst({
      where: {
        email: username.toLowerCase(),
        code: otp,
        expires_at: { gt: new Date() }
      }
    });

    if (!record) {
      return res.status(400).json({ error: "Session expired or invalid OTP" });
    }
    
    // Reset password
    const result = await authService.resetPasswordByUsername(username, newPassword);
    
    // Delete OTP records for this user
    await prisma.verificationCode.deleteMany({
      where: { email: username.toLowerCase() }
    });

    res.json(result);
  } catch (err) { next(err); }
}

async function resetPasswordDirect(req, res, next) {
  try {
    const { username, newPassword } = req.body;
    if (!username || !newPassword) {
      return res.status(400).json({ error: "Username and new password required" });
    }
    const result = await authService.resetPasswordByUsername(username, newPassword);
    res.json(result);
  } catch (err) { next(err); }
}

async function verifyTempCredentials(req, res, next) {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({ error: "Username and password required" });
    }
    const result = await authService.verifyTempCredentials(username, password);
    res.json(result);
  } catch (err) { next(err); }
}

module.exports = {
  register,
  login,
  refresh,
  me,
  logout,
  activateAccount,
  getRecoveryHints,
  recoverPassword,
  verifyInstitutionalCode,
  sendOTP,
  verifyOTP,
  resetPasswordOTP,
  verifyTempCredentials,
  resetPasswordDirect
};
