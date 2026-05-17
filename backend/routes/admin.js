const express = require("express");
const router = express.Router();
const ctrl = require("../controllers/adminController");
const { runProductionSeed } = require("../controllers/seedController");
const { authenticate, requireRole } = require("../middlewares/auth");
const { generalLimiter } = require("../middlewares/rateLimit");

const isAdminOrSpoc = requireRole("admin", "spoc");
const isInternOrAbove = requireRole("admin", "spoc", "intern");
const isAdminOnly = requireRole("admin");

router.get("/members", authenticate, isAdminOrSpoc, ctrl.getMembers);
router.post(
  "/members",
  authenticate,
  isAdminOrSpoc,
  generalLimiter,
  ctrl.createMember,
);
router.post(
  "/members/bulk",
  authenticate,
  isAdminOrSpoc,
  generalLimiter,
  ctrl.createBulkMembers,
);
router.delete("/members/:id", authenticate, isAdminOrSpoc, ctrl.deleteMember);
router.patch(
  "/members/:id/activate",
  authenticate,
  isAdminOrSpoc,
  ctrl.activateMember,
);
router.patch(
  "/members/:id/deactivate",
  authenticate,
  isAdminOrSpoc,
  ctrl.deactivateMember,
);
router.patch("/members/:id/role", authenticate, isAdminOnly, ctrl.assignRole);
router.patch(
  "/members/:id/verify",
  authenticate,
  isAdminOrSpoc,
  ctrl.verifyMember,
);

router.get("/stats", authenticate, isAdminOrSpoc, ctrl.getStats);
router.get("/reports", authenticate, isAdminOrSpoc, ctrl.getReports);

router.get("/institutions", authenticate, isAdminOnly, ctrl.getInstitutions);
router.post(
  "/institutions",
  authenticate,
  isAdminOnly,
  generalLimiter,
  ctrl.createInstitution,
);
router.post(
  "/temp-credentials/bulk",
  authenticate,
  isAdminOrSpoc,
  generalLimiter,
  ctrl.createBulkTempIds,
);
router.get(
  "/temp-credentials",
  authenticate,
  isAdminOrSpoc,
  ctrl.getTempCredentials,
);
router.post(
  "/generate-spoc-qr",
  authenticate,
  isAdminOrSpoc,
  ctrl.generateSpocQR,
);
router.delete(
  "/institutions/:id",
  authenticate,
  isAdminOnly,
  ctrl.deleteInstitution,
);

router.get("/appointments", authenticate, isAdminOrSpoc, ctrl.getAppointments);
router.get("/peer-sessions", authenticate, isAdminOrSpoc, ctrl.getPeerSessions);
router.get(
  "/blackbox-sessions",
  authenticate,
  isAdminOrSpoc,
  ctrl.getBlackboxSessions,
);
router.get(
  "/blackbox-entries/flagged",
  authenticate,
  isAdminOrSpoc,
  ctrl.getFlaggedEntries,
);

router.get("/escalations", authenticate, isAdminOrSpoc, ctrl.getEscalations);
router.post("/escalations", authenticate, isAdminOrSpoc, ctrl.createEscalation);
router.patch(
  "/escalations/:id/approve",
  authenticate,
  isAdminOnly,
  ctrl.approveEscalation,
);
router.patch(
  "/escalations/:id/reject",
  authenticate,
  isAdminOnly,
  ctrl.rejectEscalation,
);
router.post(
  "/escalations/emergency-contact",
  authenticate,
  isAdminOrSpoc,
  ctrl.getEmergencyContact,
);

router.post(
  "/credits/grant-bulk",
  authenticate,
  isAdminOrSpoc,
  generalLimiter,
  ctrl.grantCreditsBulk,
);
router.get("/credits/pool", authenticate, isAdminOrSpoc, ctrl.getPoolBalance);
router.get("/audit-logs", authenticate, isAdminOrSpoc, ctrl.getAuditLogs);

// Training Modules
router.get(
  "/training-modules",
  authenticate,
  isInternOrAbove,
  ctrl.getTrainingModules,
);
router.post(
  "/training-modules",
  authenticate,
  isAdminOnly,
  ctrl.upsertTrainingModule,
);
router.delete(
  "/training-modules/:id",
  authenticate,
  isAdminOnly,
  ctrl.deleteTrainingModule,
);

// Intern Referral Codes
router.get(
  "/intern-referral-codes",
  authenticate,
  isAdminOrSpoc,
  ctrl.getReferralCodes,
);
router.post(
  "/intern-referral-codes",
  authenticate,
  isAdminOrSpoc,
  ctrl.createReferralCode,
);
router.post(
  "/intern-referral-codes/redeem",
  authenticate,
  ctrl.redeemReferralCode,
);

// Deletion Requests
router.get(
  "/deletion-requests",
  authenticate,
  isAdminOrSpoc,
  ctrl.getDeletionRequests,
);
router.post(
  "/deletion-requests/:notificationId/approve",
  authenticate,
  isAdminOnly,
  ctrl.approveDeletion,
);
router.post(
  "/deletion-requests/:notificationId/reject",
  authenticate,
  isAdminOnly,
  ctrl.rejectDeletion,
);

// Production Seed (admin only — run once to populate demo data)
router.post("/seed", authenticate, runProductionSeed);

module.exports = router;
