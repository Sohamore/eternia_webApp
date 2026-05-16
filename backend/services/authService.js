const bcrypt = require("bcryptjs");
const prisma = require("../prisma/client");
const { signToken, signRefreshToken } = require("../utils/jwt");
const { generateInstCode, generateStudentId } = require("../utils/helpers");
const logger = require("../utils/logger");

async function registerUser(username, password, metadata = {}) {
  const email = `${username.toLowerCase()}@eternia.local`;

  // Check if username already exists
  const existing = await prisma.user.findFirst({
    where: { email },
  });
  if (existing) {
    throw Object.assign(new Error("Username already taken"), { status: 409 });
  }

  const password_hash = await bcrypt.hash(password, 12);

  // Generate student ID if student role
  const role = metadata.role || "student";
  let studentId = null;
  if (role === "student") {
    // Institution code is derived after we know institution_id
    studentId = generateStudentId(metadata.institutionCode || "INDP");
  }

  // Create user + profile in transaction
  const result = await prisma.$transaction(async (tx) => {
    const user = await tx.user.create({
      data: { email, password_hash },
    });

    const profile = await tx.profile.create({
      data: {
        id: user.id,
        username: username.toLowerCase(),
        role,
        institution_id: metadata.institution_id || null,
        student_id: studentId,
        specialty: metadata.specialty || null,
      },
    });

    await tx.userRole.create({
      data: { user_id: user.id, role },
    });

    // Welcome bonus: 100 ECC credits
    await tx.creditTransaction.create({
      data: {
        user_id: user.id,
        delta: 100,
        type: "grant",
        notes: "Welcome bonus",
      },
    });

    // Create empty user_private record
    await tx.userPrivate.create({
      data: { user_id: user.id },
    });

    return { user, profile };
  });

  const token = signToken({ userId: result.user.id });
  const refreshToken = signRefreshToken({ userId: result.user.id });

  return {
    token,
    refreshToken,
    user: {
      id: result.profile.id,
      username: result.profile.username,
      role: result.profile.role,
      institution_id: result.profile.institution_id,
      is_active: result.profile.is_active,
      is_verified: result.profile.is_verified,
      avatar_url: result.profile.avatar_url,
      specialty: result.profile.specialty,
      bio: result.profile.bio,
      total_sessions: result.profile.total_sessions,
      streak_days: result.profile.streak_days,
      training_status: result.profile.training_status,
      training_progress: result.profile.training_progress,
      created_at: result.profile.created_at,
      student_id: result.profile.student_id,
    },
  };
}

async function loginUser(username, password) {
  console.log("Login attempt:");
  const input = username.toLowerCase().trim();
  const emailsToTry = input.includes("@")
    ? [input]
    : [`${input}@eternia.local`, `${input}@eternia.com`];

  let user = null;
  for (const email of emailsToTry) {
    user = await prisma.user.findUnique({ where: { email } });
    if (user) break;
  }

  if (!user) {
    console.log(`[AuthService] User not found: ${input}`);
    throw Object.assign(new Error("Invalid credentials"), { status: 401 });
  }

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    console.log(`[AuthService] Invalid password for: ${input}`);
    throw Object.assign(new Error("Invalid credentials"), { status: 401 });
  }

  const profile = await prisma.profile.findUnique({
    where: { id: user.id },
    select: {
      id: true,
      username: true,
      role: true,
      institution_id: true,
      is_active: true,
      is_verified: true,
      avatar_url: true,
      specialty: true,
      bio: true,
      total_sessions: true,
      streak_days: true,
      training_status: true,
      training_progress: true,
      created_at: true,
      student_id: true,
    },
  });

  if (!profile || !profile.is_active) {
    throw Object.assign(new Error("Account is deactivated"), { status: 403 });
  }

  // Update last_login
  await prisma.profile.update({
    where: { id: user.id },
    data: { last_login: new Date() },
  });

  // Credit balance
  const txAgg = await prisma.creditTransaction.aggregate({
    where: { user_id: user.id },
    _sum: { delta: true },
  });
  const creditBalance = txAgg._sum.delta || 0;

  const token = signToken({ userId: user.id });
  const refreshToken = signRefreshToken({ userId: user.id });

  return { token, refreshToken, user: profile, creditBalance };
}

async function refreshUserToken(refreshToken) {
  const { verifyRefreshToken } = require("../utils/jwt");
  const decoded = verifyRefreshToken(refreshToken);

  const profile = await prisma.profile.findUnique({
    where: { id: decoded.userId },
    select: { id: true, is_active: true },
  });

  if (!profile || !profile.is_active) {
    throw Object.assign(new Error("User not found or inactive"), {
      status: 401,
    });
  }

  const token = signToken({ userId: decoded.userId });
  const newRefreshToken = signRefreshToken({ userId: decoded.userId });

  return { token, refreshToken: newRefreshToken };
}

async function getCurrentUser(userId) {
  const profile = await prisma.profile.findUnique({
    where: { id: userId },
    select: {
      id: true,
      username: true,
      role: true,
      institution_id: true,
      is_active: true,
      is_verified: true,
      avatar_url: true,
      specialty: true,
      bio: true,
      total_sessions: true,
      streak_days: true,
      training_status: true,
      training_progress: true,
      created_at: true,
      student_id: true,
    },
  });

  if (!profile) {
    throw Object.assign(new Error("Profile not found"), { status: 404 });
  }

  const txAgg = await prisma.creditTransaction.aggregate({
    where: { user_id: userId },
    _sum: { delta: true },
  });
  const creditBalance = txAgg._sum.delta || 0;

  return { user: profile, creditBalance };
}

async function activateAccount(
  tempCredentialId,
  username,
  password,
  emergencyContact = {},
  studentIdData = {},
) {
  const tempCred = await prisma.tempCredential.findUnique({
    where: { id: tempCredentialId },
    include: { institution: true },
  });

  if (!tempCred)
    throw Object.assign(new Error("Invalid activation token"), { status: 400 });
  if (tempCred.status === "activated")
    throw Object.assign(new Error("Token already used"), { status: 400 });
  if (new Date() > new Date(tempCred.expires_at))
    throw Object.assign(new Error("Token expired"), { status: 400 });

  // Check username uniqueness in institution
  const existingProfile = await prisma.profile.findFirst({
    where: {
      username: username.toLowerCase(),
      institution_id: tempCred.institution_id,
    },
  });
  if (existingProfile)
    throw Object.assign(new Error("Username already taken"), { status: 409 });

  const email = `${username.toLowerCase()}@eternia.local`;
  const password_hash = await bcrypt.hash(password, 12);
  const instCode = generateInstCode(tempCred.institution?.name);
  const studentId = generateStudentId(instCode);

  // Verify student ID if provided
  let isVerified = false;
  if (studentIdData.rawId && studentIdData.idType) {
    const { hashStudentId } = require("../utils/helpers");
    const hash = hashStudentId(
      tempCred.institution_id,
      studentIdData.idType,
      studentIdData.rawId,
    );
    const found = await prisma.institutionStudentId.findFirst({
      where: {
        institution_id: tempCred.institution_id,
        id_type: studentIdData.idType,
        student_id_hash: hash,
        is_claimed: false,
      },
    });
    if (found) {
      await prisma.institutionStudentId.update({
        where: { id: found.id },
        data: { is_claimed: true },
      });
      isVerified = true;
    }
  }

  const result = await prisma.$transaction(async (tx) => {
    const user = await tx.user.create({ data: { email, password_hash } });

    const profile = await tx.profile.create({
      data: {
        id: user.id,
        username: username.toLowerCase(),
        role: "student",
        institution_id: tempCred.institution_id,
        is_verified: isVerified,
        student_id: studentId,
      },
    });

    await tx.userRole.create({ data: { user_id: user.id, role: "student" } });

    await tx.creditTransaction.create({
      data: {
        user_id: user.id,
        delta: 100,
        type: "grant",
        notes: "Welcome bonus",
      },
    });

    await tx.userPrivate.create({
      data: {
        user_id: user.id,
        emergency_name_encrypted: emergencyContact.name || null,
        emergency_phone_encrypted: emergencyContact.phone || null,
        emergency_relation: emergencyContact.relation || null,
        contact_is_self: emergencyContact.isSelf || false,
      },
    });

    await tx.tempCredential.update({
      where: { id: tempCredentialId },
      data: { status: "activated", auth_user_id: user.id },
    });

    return { user, profile };
  });

  const token = signToken({ userId: result.user.id });
  const refreshToken = signRefreshToken({ userId: result.user.id });

  return { token, refreshToken, user: result.profile };
}

async function recoverPassword(username, fragmentPairs, emojiPattern) {
  const email = `${username.toLowerCase()}@eternia.local`;
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) throw Object.assign(new Error("User not found"), { status: 404 });

  const recovery = await prisma.recoveryCredential.findUnique({
    where: { user_id: user.id },
  });
  if (!recovery)
    throw Object.assign(new Error("No recovery credentials set up"), {
      status: 404,
    });

  let storedPairs, storedEmoji;
  try {
    storedPairs = JSON.parse(recovery.fragment_pairs_encrypted);
    storedEmoji = JSON.parse(recovery.emoji_pattern_encrypted);
  } catch {
    throw Object.assign(new Error("Invalid recovery data"), { status: 500 });
  }

  // Verify fragment pairs
  const pairsMatch = fragmentPairs.every(
    (pair, i) =>
      storedPairs[i] &&
      pair.answer?.toLowerCase().trim() ===
      storedPairs[i].answer?.toLowerCase().trim(),
  );
  // Verify emoji pattern
  const emojiMatch = emojiPattern.every((e, i) => storedEmoji[i] === e);

  if (!pairsMatch || !emojiMatch) {
    throw Object.assign(new Error("Recovery verification failed"), {
      status: 401,
    });
  }

  return { userId: user.id, verified: true };
}

async function updatePassword(userId, newPassword) {
  const password_hash = await bcrypt.hash(newPassword, 12);
  await prisma.user.update({ where: { id: userId }, data: { password_hash } });
}

async function getRecoveryHints(username) {
  const email = `${username.toLowerCase()}@eternia.local`;
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) return { hasRecovery: false };

  const recovery = await prisma.recoveryCredential.findUnique({
    where: { user_id: user.id },
  });
  if (!recovery) return { hasRecovery: false };

  let storedPairs;
  try {
    storedPairs = JSON.parse(recovery.fragment_pairs_encrypted);
  } catch {
    return { hasRecovery: false };
  }

  return {
    hasRecovery: true,
    hints: storedPairs.map((p) => ({ hint: p.hint })),
  };
}

async function verifyInstitutionalCode(code) {
  console.log(`[AuthService] Verifying institutional code: "${code}"`);
  const institution = await prisma.institution.findFirst({
    where: { 
      OR: [
        { eternia_code_hash: code },
        { name: code } // Fallback for simple testing
      ]
    }
  });

  if (!institution) {
    throw Object.assign(new Error("Invalid institution code"), { status: 404 });
  }

  // Find a pending temp credential for this institution
  let tempCred = await prisma.tempCredential.findFirst({
    where: { 
      institution_id: institution.id,
      status: "pending"
    }
  });

  if (!tempCred) {
    // Create a temporary credential if none available (for onboarding flow)
    tempCred = await prisma.tempCredential.create({
      data: {
        institution_id: institution.id,
        username: "new_student_" + Math.random().toString(36).substring(7),
        expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      }
    });
  }

  return { 
    success: true, 
    institutionName: institution.name, 
    tempCredentialId: tempCred.id 
  };
}

async function resetPasswordByUsername(username, newPassword) {
  const profile = await prisma.profile.findFirst({
    where: { username: username.toLowerCase() }
  });
  if (!profile) throw Object.assign(new Error("User not found"), { status: 404 });
  
  const password_hash = await bcrypt.hash(newPassword, 12);
  
  await prisma.user.update({
    where: { id: profile.id },
    data: { password_hash }
  });
  
  return { success: true, message: "Password updated successfully" };
}

async function verifyTempCredentials(username, password) {
  const input = username.toLowerCase().trim();
  const emailsToTry = [input, `${input}@eternia.local`, `${input}@eternia.com`];

  let user = null;
  for (const email of emailsToTry) {
    user = await prisma.user.findUnique({ where: { email } });
    if (user) break;
  }

  if (!user) {
    throw Object.assign(new Error("User not found"), { status: 404 });
  }

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    throw Object.assign(new Error("Invalid credentials"), { status: 401 });
  }

  return { success: true, message: "Credentials verified" };
}

module.exports = {
  registerUser,
  loginUser,
  refreshUserToken,
  getCurrentUser,
  activateAccount,
  recoverPassword,
  updatePassword,
  getRecoveryHints,
  verifyInstitutionalCode,
  resetPasswordByUsername,
  verifyTempCredentials,
};
