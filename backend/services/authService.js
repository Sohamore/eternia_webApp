const bcrypt = require("bcryptjs");
const prisma = require("../prisma/client");
const { signToken, signRefreshToken } = require("../utils/jwt");
const { generateInstCode, generateStudentId } = require("../utils/helpers");
const logger = require("../utils/logger");

// ─── Fix 1: registerUser ────────────────────────────────────────────────────
// UUID-based internal email avoids UNIQUE collisions across institutions.
// Username uniqueness is checked globally via the Profile table.
// Emergency contact is stored in userPrivate from registration metadata.
async function registerUser(username, password, metadata = {}) {
  const cleanUsername = username.toLowerCase().trim();

  const institutionId = metadata.institution_id || null;

  // Check username uniqueness GLOBALLY (Eternia uses globally unique pseudonyms)
  const existingProfile = await prisma.profile.findFirst({
    where: { username: cleanUsername },
  });
  if (existingProfile) {
    throw Object.assign(new Error("Username already taken"), { status: 409 });
  }

  // Generate truly unique internal email (never shown to users - avoids global collision)
  const uniqueTag = require("crypto")
    .randomUUID()
    .replace(/-/g, "")
    .slice(0, 10);
  const email = `${cleanUsername}_${uniqueTag}@eternia.local`;

  const password_hash = await bcrypt.hash(password, 12);
  const role = metadata.role || "student";
  let studentId = null;
  if (role === "student") {
    studentId = generateStudentId(metadata.institutionCode || "INDP");
  }

  // Handle emergency contact from metadata
  const emergencyContact = metadata.emergencyContact || {};

  const result = await prisma.$transaction(async (tx) => {
    const user = await tx.user.create({ data: { email, password_hash } });

    const profile = await tx.profile.create({
      data: {
        id: user.id,
        username: cleanUsername,
        role,
        institution_id: institutionId,
        student_id: studentId,
        specialty: metadata.specialty || null,
      },
    });

    await tx.userRole.create({ data: { user_id: user.id, role } });

    // Welcome bonus: 100 ECC credits
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

// ─── Fix 2: loginUser ───────────────────────────────────────────────────────
// Primary path is Profile-based username lookup so accounts registered with
// UUID emails (Fix 1 / Fix 3) are still found correctly.
// A real-email path and a legacy @eternia.local fallback are retained.
async function loginUser(username, password) {
  const input = username.toLowerCase().trim();

  let user = null;
  let profile = null;

  if (
    input.includes("@") &&
    !input.endsWith("@eternia.local") &&
    !input.endsWith("@eternia.com")
  ) {
    // Real email address - try direct lookup
    user = await prisma.user.findUnique({ where: { email: input } });
    if (user) {
      profile = await prisma.profile.findUnique({ where: { id: user.id } });
    }
  }

  if (!user) {
    // Username lookup via Profile (primary path for app + website users)
    profile = await prisma.profile.findFirst({
      where: { username: input },
    });
    if (profile) {
      user = await prisma.user.findUnique({ where: { id: profile.id } });
    }
  }

  if (!user) {
    // Legacy fallback: old-style @eternia.local email (pre-UUID accounts)
    const legacyEmail = `${input}@eternia.local`;
    user = await prisma.user.findUnique({ where: { email: legacyEmail } });
    if (user) {
      profile = await prisma.profile.findUnique({ where: { id: user.id } });
    }
  }

  if (!user || !profile) {
    throw Object.assign(new Error("Invalid credentials"), { status: 401 });
  }

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    throw Object.assign(new Error("Invalid credentials"), { status: 401 });
  }

  if (!profile.is_active) {
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

  const fullProfile = await prisma.profile.findUnique({
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

  return { token, refreshToken, user: fullProfile, creditBalance };
}

// ─── Unchanged ───────────────────────────────────────────────────────────────
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

// ─── Unchanged ───────────────────────────────────────────────────────────────
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

// ─── Fix 3: activateAccount ─────────────────────────────────────────────────
// UUID-based email prevents collisions when the same username is chosen at
// different institutions. Username uniqueness is now checked GLOBALLY.
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

  // Check username uniqueness GLOBALLY (not just per-institution)
  const existingProfile = await prisma.profile.findFirst({
    where: { username: username.toLowerCase() },
  });
  if (existingProfile)
    throw Object.assign(new Error("Username already taken"), { status: 409 });

  // UUID-based internal email - never shown to users, avoids global collision
  const uniqueTag = require("crypto")
    .randomUUID()
    .replace(/-/g, "")
    .slice(0, 10);
  const email = `${username.toLowerCase()}_${uniqueTag}@eternia.local`;

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

// ─── Fix 5: recoverPassword ──────────────────────────────────────────────────
// Look up the user via Profile (username) instead of the old email pattern
// so UUID-email accounts are found correctly.
async function recoverPassword(username, fragmentPairs, emojiPattern) {
  const profile = await prisma.profile.findFirst({
    where: { username: username.toLowerCase().trim() },
  });
  if (!profile)
    throw Object.assign(new Error("User not found"), { status: 404 });

  const recovery = await prisma.recoveryCredential.findUnique({
    where: { user_id: profile.id },
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

  return { userId: profile.id, verified: true };
}

// ─── Unchanged ───────────────────────────────────────────────────────────────
async function updatePassword(userId, newPassword) {
  const password_hash = await bcrypt.hash(newPassword, 12);
  await prisma.user.update({ where: { id: userId }, data: { password_hash } });
}

// ─── Fix 4: getRecoveryHints ─────────────────────────────────────────────────
// Look up the user via Profile (username) instead of the old email pattern
// so UUID-email accounts are found correctly.
async function getRecoveryHints(username) {
  const profile = await prisma.profile.findFirst({
    where: { username: username.toLowerCase().trim() },
  });
  if (!profile) return { hasRecovery: false };

  const recovery = await prisma.recoveryCredential.findUnique({
    where: { user_id: profile.id },
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

// ─── Fix 6: verifyInstitutionalCode ─────────────────────────────────────────
// Now returns institutionId so the client can pass it through the onboarding flow.
async function verifyInstitutionalCode(code) {
  console.log(`[AuthService] Verifying institutional code: "${code}"`);
  const institution = await prisma.institution.findFirst({
    where: {
      OR: [
        { eternia_code_hash: code },
        { name: code }, // Fallback for simple testing
      ],
    },
  });

  if (!institution) {
    throw Object.assign(new Error("Invalid institution code"), { status: 404 });
  }

  // Find a pending temp credential for this institution
  let tempCred = await prisma.tempCredential.findFirst({
    where: {
      institution_id: institution.id,
      status: "pending",
    },
  });

  if (!tempCred) {
    // Create a temporary credential if none available (for onboarding flow)
    tempCred = await prisma.tempCredential.create({
      data: {
        institution_id: institution.id,
        username: "new_student_" + Math.random().toString(36).substring(7),
        expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      },
    });
  }

  return {
    success: true,
    institutionName: institution.name,
    institutionId: institution.id,
    tempCredentialId: tempCred.id,
  };
}

// ─── Unchanged ───────────────────────────────────────────────────────────────
async function resetPasswordByUsername(username, newPassword) {
  const profile = await prisma.profile.findFirst({
    where: { username: username.toLowerCase() },
  });
  if (!profile)
    throw Object.assign(new Error("User not found"), { status: 404 });

  const password_hash = await bcrypt.hash(newPassword, 12);

  await prisma.user.update({
    where: { id: profile.id },
    data: { password_hash },
  });

  return { success: true, message: "Password updated successfully" };
}

// ─── Fix 7: verifyTempCredentials ────────────────────────────────────────────
// Primary lookup is now via Profile (username) so UUID-email accounts work.
// Legacy email fallback is kept for old accounts.
async function verifyTempCredentials(username, password) {
  const input = username.toLowerCase().trim();

  let user = null;

  // Primary: Profile-based lookup
  const profile = await prisma.profile.findFirst({
    where: { username: input },
  });
  if (profile) {
    user = await prisma.user.findUnique({ where: { id: profile.id } });
  }

  if (!user) {
    // Legacy email fallback
    const emailsToTry = [
      `${input}@eternia.local`,
      `${input}@eternia.com`,
      input,
    ];
    for (const email of emailsToTry) {
      user = await prisma.user.findUnique({ where: { email } });
      if (user) break;
    }
  }

  if (!user) throw Object.assign(new Error("User not found"), { status: 404 });

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid)
    throw Object.assign(new Error("Invalid credentials"), { status: 401 });

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
