const crypto = require("crypto");
const { v4: uuidv4 } = require("uuid");

function isValidUUID(str) {
  const uuidRegex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  return uuidRegex.test(str);
}

function isPositiveInt(val) {
  return Number.isInteger(val) && val > 0;
}

function sanitizeString(input, maxLen = 1000) {
  if (typeof input !== "string") return "";
  return input.trim().slice(0, maxLen).replace(/\0/g, "");
}

function hashString(str) {
  return crypto.createHash("sha256").update(str).digest("hex");
}

function hashStudentId(institutionId, idType, rawId) {
  return crypto
    .createHash("sha256")
    .update(`eternia:${institutionId}:${idType}:${rawId}`)
    .digest("hex");
}

function getClientIP(req) {
  return (
    req.headers["x-forwarded-for"]?.split(",")[0]?.trim() ||
    req.headers["x-real-ip"] ||
    req.headers["cf-connecting-ip"] ||
    req.socket?.remoteAddress ||
    "unknown"
  );
}

function generateInstCode(institutionName) {
  if (!institutionName) return "INDP";
  const code = institutionName
    .replace(/[^a-zA-Z0-9]/g, "")
    .toUpperCase()
    .slice(0, 4);
  return code || "INDP";
}

function generateStudentId(instCode) {
  const code = (instCode || "INDP").slice(0, 4).toUpperCase();
  // Use crypto random bytes — never collides, never resets on restart
  const random = crypto.randomBytes(4).toString("hex").toUpperCase();
  return `ETN-${code}-${random}`;
}

module.exports = {
  isValidUUID,
  isPositiveInt,
  sanitizeString,
  hashString,
  hashStudentId,
  getClientIP,
  generateInstCode,
  generateStudentId,
  uuidv4,
};
