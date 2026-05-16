const adminService = require('../services/adminService');
const creditsService = require('../services/creditsService');

async function getMembers(req, res, next) {
  try {
    const members = await adminService.getMembers(req.user.role, req.user.institution_id, req.query.search);
    res.json({ members });
  } catch (err) { next(err); }
}

async function getStats(req, res, next) {
  try {
    const stats = await adminService.getStats(req.user.role, req.user.institution_id);
    res.json({ stats });
  } catch (err) { next(err); }
}

async function createMember(req, res, next) {
  try {
    const profile = await adminService.createMember(req.user.id, req.user.role, req.user.institution_id, req.body);
    res.status(201).json({ profile });
  } catch (err) { next(err); }
}

async function createBulkMembers(req, res, next) {
  try {
    const { institution_id, count, prefix, role } = req.body;
    const result = await adminService.createBulkMembers(req.user.id, institution_id, count, prefix, role || 'student');
    res.json(result);
  } catch (err) { next(err); }
}

async function deleteMember(req, res, next) {
  try {
    const result = await adminService.deleteMember(req.user.id, req.user.role, req.user.institution_id, req.params.id);
    res.json(result);
  } catch (err) { next(err); }
}

async function activateMember(req, res, next) {
  try {
    const result = await adminService.toggleMemberStatus(req.user.id, req.params.id, true);
    res.json(result);
  } catch (err) { next(err); }
}

async function deactivateMember(req, res, next) {
  try {
    const result = await adminService.toggleMemberStatus(req.user.id, req.params.id, false);
    res.json(result);
  } catch (err) { next(err); }
}

async function verifyMember(req, res, next) {
  try {
    const profile = await adminService.verifyMember(req.user.id, req.params.id, req.body);
    res.json({ profile });
  } catch (err) { next(err); }
}

async function assignRole(req, res, next) {
  try {
    const { role, institution_id } = req.body;
    const profile = await adminService.assignRole(req.user.id, req.params.id, role, institution_id);
    res.json({ profile });
  } catch (err) { next(err); }
}

async function getInstitutions(req, res, next) {
  try {
    const institutions = await adminService.getInstitutions();
    res.json({ institutions });
  } catch (err) { next(err); }
}

async function createInstitution(req, res, next) {
  try {
    const institution = await adminService.createInstitution(req.user.id, req.body);
    res.status(201).json({ institution });
  } catch (err) { next(err); }
}

async function createBulkTempIds(req, res, next) {
  try {
    const { institution_id, count, prefix } = req.body;
    const result = await adminService.createBulkTempIds(req.user.id, institution_id, count, prefix);
    res.json(result);
  } catch (err) { next(err); }
}

async function getTempCredentials(req, res, next) {
  try {
    const credentials = await adminService.getTempCredentials(req.query.institution_id);
    res.json({ credentials });
  } catch (err) { next(err); }
}

async function deleteInstitution(req, res, next) {
  try {
    const result = await adminService.deleteInstitution(req.user.id, req.params.id);
    res.json(result);
  } catch (err) { next(err); }
}

async function getAppointments(req, res, next) {
  try {
    const appointments = await adminService.getAdminAppointments();
    res.json({ appointments });
  } catch (err) { next(err); }
}

async function getPeerSessions(req, res, next) {
  try {
    const sessions = await adminService.getAdminPeerSessions();
    res.json({ sessions });
  } catch (err) { next(err); }
}

async function getBlackboxSessions(req, res, next) {
  try {
    const sessions = await adminService.getAdminBlackboxSessions();
    res.json({ sessions });
  } catch (err) { next(err); }
}

async function getFlaggedEntries(req, res, next) {
  try {
    const entries = await adminService.getFlaggedEntries();
    res.json({ entries });
  } catch (err) { next(err); }
}

async function getEscalations(req, res, next) {
  try {
    const escalations = await adminService.getEscalations(req.query.status);
    res.json({ escalations });
  } catch (err) { next(err); }
}

async function createEscalation(req, res, next) {
  try {
    const { justification } = req.body;
    const escalation = await adminService.createEscalation(req.user.id, justification);
    res.json({ escalation });
  } catch (err) { next(err); }
}

async function approveEscalation(req, res, next) {
  try {
    const escalation = await adminService.updateEscalationStatus(req.user.id, req.params.id, 'approved');
    res.json({ escalation });
  } catch (err) { next(err); }
}

async function rejectEscalation(req, res, next) {
  try {
    const escalation = await adminService.updateEscalationStatus(req.user.id, req.params.id, 'rejected');
    res.json({ escalation });
  } catch (err) { next(err); }
}

async function grantCreditsBulk(req, res, next) {
  try {
    let { institution_id, amount } = req.body;
    
    // Security: If actor is a SPOC, force the institution_id to be their own
    if (req.user.role === 'spoc') {
      institution_id = req.user.institution_id;
    }
    
    if (!institution_id || !amount) return res.status(400).json({ error: 'institution_id and amount required' });
    const result = await creditsService.grantCreditsBulk(req.user.id, institution_id, amount);
    res.json(result);
  } catch (err) { next(err); }
}

async function getAuditLogs(req, res, next) {
  try {
    const logs = await adminService.getAuditLogs();
    res.json({ logs });
  } catch (err) { next(err); }
}

async function generateSpocQR(req, res, next) {
  try {
    const result = await adminService.generateSpocQR(req.user.id, req.user.institution_id);
    res.json(result);
  } catch (err) { next(err); }
}

// Training
async function getTrainingModules(req, res, next) {
  try {
    const modules = await adminService.getTrainingModules();
    res.json({ modules });
  } catch (err) { next(err); }
}

async function upsertTrainingModule(req, res, next) {
  try {
    const module = await adminService.upsertTrainingModule(req.body);
    res.json({ module });
  } catch (err) { next(err); }
}

async function deleteTrainingModule(req, res, next) {
  try {
    await adminService.deleteTrainingModule(req.params.id);
    res.json({ success: true });
  } catch (err) { next(err); }
}

// Referral Codes
async function getReferralCodes(req, res, next) {
  try {
    const codes = await adminService.getReferralCodes(req.user.role, req.user.institution_id);
    res.json({ codes });
  } catch (err) { next(err); }
}

async function createReferralCode(req, res, next) {
  try {
    const code = await adminService.createReferralCode(req.user.id, req.user.role, req.user.institution_id, req.body);
    res.status(201).json({ code });
  } catch (err) { next(err); }
}

async function redeemReferralCode(req, res, next) {
  try {
    const { code } = req.body;
    const result = await adminService.redeemReferralCode(req.user.id, code);
    res.json(result);
  } catch (err) { next(err); }
}

async function getDeletionRequests(req, res, next) {
  try {
    const requests = await adminService.getDeletionRequests();
    res.json({ requests });
  } catch (err) { next(err); }
}

async function approveDeletion(req, res, next) {
  try {
    const result = await adminService.approveDeletion(req.user.id, req.params.notificationId);
    res.json(result);
  } catch (err) { next(err); }
}

async function rejectDeletion(req, res, next) {
  try {
    const result = await adminService.rejectDeletion(req.user.id, req.params.notificationId);
    res.json(result);
  } catch (err) { next(err); }
}

async function getReports(req, res, next) {
  try {
    const reports = await adminService.getReports(req.user.institution_id, req.query.days);
    res.json({ reports });
  } catch (err) { next(err); }
}

async function getEmergencyContact(req, res, next) {
  try {
    const { student_id } = req.body;
    if (!student_id) return res.status(400).json({ error: 'student_id required' });
    const contact = await adminService.getEmergencyContact(student_id);
    res.json({ contact });
  } catch (err) { next(err); }
}

async function getPoolBalance(req, res, next) {
  try {
    const balance = await adminService.getPoolBalance(req.user.institution_id);
    res.json({ balance });
  } catch (err) { next(err); }
}

module.exports = {
  getMembers, getStats, createMember, deleteMember, activateMember, deactivateMember,
  getInstitutions, createInstitution, deleteInstitution,
  getAppointments, getPeerSessions, getBlackboxSessions, getFlaggedEntries,
  getEscalations, createEscalation, approveEscalation, rejectEscalation, grantCreditsBulk, getAuditLogs, assignRole, verifyMember, createBulkTempIds, getTempCredentials, createBulkMembers, generateSpocQR,
  getTrainingModules, upsertTrainingModule, deleteTrainingModule, getReferralCodes, createReferralCode, redeemReferralCode,
  getDeletionRequests, approveDeletion, rejectDeletion,
  getReports, getEmergencyContact, getPoolBalance
};

