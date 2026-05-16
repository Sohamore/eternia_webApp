const prisma = require('../prisma/client');
const { hashStudentId } = require('../utils/helpers');

async function getMyProfile(req, res, next) {
  try {
    const profile = await prisma.profile.findUnique({
      where: { id: req.user.id },
      select: {
        id: true, username: true, role: true, institution_id: true,
        is_active: true, is_verified: true, avatar_url: true, specialty: true,
        bio: true, total_sessions: true, streak_days: true, training_status: true,
        training_progress: true, created_at: true, student_id: true, last_login: true,
        institution: { select: { id: true, name: true } }
      }
    });
    if (!profile) return res.status(404).json({ error: 'Profile not found' });
    res.json({ profile });
  } catch (err) { next(err); }
}

async function getMyPrivateData(req, res, next) {
  try {
    const data = await prisma.userPrivate.findUnique({
      where: { user_id: req.user.id }
    });
    res.json({ data: data || {} });
  } catch (err) { next(err); }
}

async function updateMyProfile(req, res, next) {
  try {
    const { avatar_url, specialty, bio, training_status, training_progress } = req.body;
    const profile = await prisma.profile.update({
      where: { id: req.user.id },
      data: {
        avatar_url: avatar_url !== undefined ? avatar_url : undefined,
        specialty: specialty !== undefined ? specialty : undefined,
        bio: bio !== undefined ? bio : undefined,
        training_status: training_status !== undefined ? training_status : undefined,
        training_progress: training_progress !== undefined ? training_progress : undefined,
      },
      select: {
        id: true, username: true, role: true, institution_id: true,
        is_active: true, is_verified: true, avatar_url: true, specialty: true,
        bio: true, total_sessions: true, streak_days: true, training_status: true,
        training_progress: true, created_at: true, student_id: true,
      }
    });
    res.json({ profile });
  } catch (err) { next(err); }
}

async function getProfileById(req, res, next) {
  try {
    const profile = await prisma.profile.findUnique({
      where: { id: req.params.id },
      select: {
        id: true, username: true, role: true, is_active: true, is_verified: true,
        avatar_url: true, specialty: true, bio: true, total_sessions: true,
        streak_days: true, training_status: true, created_at: true, student_id: true,
        institution: { select: { id: true, name: true } }
      }
    });
    if (!profile) return res.status(404).json({ error: 'Profile not found' });
    res.json({ profile });
  } catch (err) { next(err); }
}

async function verifyStudentId(req, res, next) {
  try {
    const { institution_id, id_type, raw_id, claim_for_user_id } = req.body;
    if (!institution_id || !id_type || !raw_id) {
      return res.status(400).json({ error: 'institution_id, id_type, and raw_id required' });
    }

    // Validate format
    if (id_type === 'apaar' && !/^\\d{12}$/.test(raw_id)) {
      return res.status(400).json({ error: 'APAAR ID must be exactly 12 digits' });
    }
    if (id_type === 'erp' && !/^[a-zA-Z0-9]{3,50}$/.test(raw_id)) {
      return res.status(400).json({ error: 'ERP ID must be 3-50 alphanumeric characters' });
    }

    const hasAny = await prisma.institutionStudentId.count({ where: { institution_id } });
    
    // If no records exist, we just let them "verify" without a real check (passthrough)
    if (hasAny === 0 && claim_for_user_id) {
      await prisma.$transaction([
        prisma.userPrivate.upsert({
          where: { user_id: claim_for_user_id },
          create: { user_id: claim_for_user_id, apaar_verified: id_type === 'apaar', erp_verified: id_type === 'erp' },
          update: { apaar_verified: id_type === 'apaar', erp_verified: id_type === 'erp' }
        }),
        prisma.profile.update({ where: { id: claim_for_user_id }, data: { is_verified: true } })
      ]);
      return res.json({ verified: true, reason: 'no_records' });
    } else if (hasAny === 0) {
      return res.json({ valid: false, reason: 'no_records' });
    }

    const hash = hashStudentId(institution_id, id_type, raw_id);
    const record = await prisma.institutionStudentId.findFirst({
      where: { institution_id, id_type, student_id_hash: hash }
    });

    if (!record) return res.json({ verified: false, reason: 'not_found' });
    if (record.is_claimed) return res.json({ verified: false, reason: 'already_claimed' });

    if (claim_for_user_id) {
      await prisma.$transaction([
        prisma.institutionStudentId.update({
          where: { id: record.id },
          data: { is_claimed: true, claimed_by: claim_for_user_id }
        }),
        prisma.userPrivate.upsert({
          where: { user_id: claim_for_user_id },
          create: { user_id: claim_for_user_id, apaar_verified: id_type === 'apaar', erp_verified: id_type === 'erp' },
          update: { apaar_verified: id_type === 'apaar', erp_verified: id_type === 'erp' }
        }),
        prisma.profile.update({ where: { id: claim_for_user_id }, data: { is_verified: true } })
      ]);
      return res.json({ verified: true, claimed: true });
    }

    res.json({ verified: true, reason: 'found' });
  } catch (err) { next(err); }
}

async function setRecoveryCredentials(req, res, next) {
  try {
    const { fragment_pairs, emoji_pattern } = req.body;
    if (!fragment_pairs || !emoji_pattern) {
      return res.status(400).json({ error: 'fragment_pairs and emoji_pattern required' });
    }

    await prisma.recoveryCredential.upsert({
      where: { user_id: req.user.id },
      create: {
        user_id: req.user.id,
        fragment_pairs_encrypted: JSON.stringify(fragment_pairs),
        emoji_pattern_encrypted: JSON.stringify(emoji_pattern),
      },
      update: {
        fragment_pairs_encrypted: JSON.stringify(fragment_pairs),
        emoji_pattern_encrypted: JSON.stringify(emoji_pattern),
      }
    });

    res.json({ success: true });
  } catch (err) { next(err); }
}

async function updateEmergencyContact(req, res, next) {
  try {
    const { emergency_name, emergency_phone, emergency_relation, contact_is_self } = req.body;
    await prisma.userPrivate.upsert({
      where: { user_id: req.user.id },
      create: {
        user_id: req.user.id,
        emergency_name_encrypted: emergency_name || null,
        emergency_phone_encrypted: emergency_phone || null,
        emergency_relation: emergency_relation || null,
        contact_is_self: contact_is_self || false,
      },
      update: {
        emergency_name_encrypted: emergency_name || null,
        emergency_phone_encrypted: emergency_phone || null,
        emergency_relation: emergency_relation || null,
        contact_is_self: contact_is_self || false,
      }
    });
    res.json({ success: true });
  } catch (err) { next(err); }
}

async function getEmergencyContact(req, res, next) {
  try {
    // Admin/SPOC only
    if (!['admin', 'spoc', 'expert', 'therapist'].includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    const privateData = await prisma.userPrivate.findUnique({
      where: { user_id: req.params.userId }
    });
    if (!privateData) return res.status(404).json({ error: 'Private data not found' });
    res.json({ data: privateData });
  } catch (err) { next(err); }
}

async function validateSpocQR(req, res, next) {
  try {
    const { qr_payload } = req.body;
    if (!qr_payload) return res.status(400).json({ error: 'qr_payload required' });

    let parsed;
    try {
      parsed = typeof qr_payload === 'string' ? JSON.parse(qr_payload) : qr_payload;
    } catch {
      return res.status(400).json({ error: 'Invalid QR format' });
    }

    const { institution_id, spoc_id, timestamp, signature } = parsed;
    if (!institution_id || !spoc_id || !timestamp || !signature) {
      return res.status(400).json({ error: 'Missing required payload fields' });
    }

    const MAX_AGE = 5 * 60 * 1000;
    if (Date.now() - timestamp > MAX_AGE) {
      return res.json({ valid: false, error: 'QR code expired. Please ask SPOC to regenerate.' });
    }

    const crypto = require('crypto');
    const expectedSignature = crypto.createHmac('sha256', process.env.JWT_SECRET || 'fallback_secret')
      .update(`${institution_id}:${spoc_id}:${timestamp}`)
      .digest('hex');

    if (signature !== expectedSignature) {
      return res.json({ valid: false, error: 'Invalid QR signature.' });
    }

    const institution = await prisma.institution.findUnique({
      where: { id: institution_id },
      select: { id: true, name: true }
    });

    if (!institution) {
      return res.json({ valid: false, error: 'Institution not found.' });
    }

    res.json({
      valid: true,
      institution_id: institution.id,
      institution_name: institution.name
    });
  } catch (err) { next(err); }
}

async function redeemReferral(req, res, next) {
  try {
    const { code } = req.body;
    if (!code) return res.status(400).json({ error: 'Referral code required' });

    const codeUpper = code.trim().toUpperCase();

    const codeRow = await prisma.internReferralCode.findFirst({
      where: { code: codeUpper }
    });

    if (!codeRow) return res.status(404).json({ error: 'Invalid referral code' });
    if (codeRow.is_used) return res.status(400).json({ error: 'This code has already been used' });
    if (codeRow.expires_at && new Date(codeRow.expires_at) < new Date()) {
      return res.status(400).json({ error: 'This code has expired' });
    }

    await prisma.$transaction([
      prisma.profile.update({
        where: { id: req.user.id },
        data: {
          training_status: 'active',
          is_verified: true,
          training_progress: [1, 2, 3, 4, 5, 6, 7]
        }
      }),
      prisma.internReferralCode.update({
        where: { id: codeRow.id },
        data: {
          is_used: true,
          assigned_to: req.user.id,
          used_at: new Date()
        }
      })
    ]);

    res.json({ success: true });
  } catch (err) { next(err); }
}

async function getTrainingModules(req, res, next) {
  try {
    const modules = await prisma.trainingModule.findMany({
      orderBy: { day_number: 'asc' }
    });
    res.json({ modules });
  } catch (err) { next(err); }
}

module.exports = {
  getMyProfile, getMyPrivateData, updateMyProfile, getProfileById,
  verifyStudentId, setRecoveryCredentials, updateEmergencyContact, getEmergencyContact,
  validateSpocQR, redeemReferral, getTrainingModules
};
