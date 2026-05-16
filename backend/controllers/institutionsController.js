const prisma = require('../prisma/client');

async function getInstitutions(req, res, next) {
  try {
    const institutions = await prisma.institution.findMany({
      where: { is_active: true },
      select: { id: true, name: true, plan_type: true, created_at: true }
    });
    res.json({ institutions });
  } catch (err) { next(err); }
}

async function getInstitutionById(req, res, next) {
  try {
    const institution = await prisma.institution.findUnique({
      where: { id: req.params.id },
      select: { id: true, name: true, plan_type: true, is_active: true, created_at: true }
    });
    if (!institution) return res.status(404).json({ error: 'Institution not found' });
    res.json({ institution });
  } catch (err) { next(err); }
}

async function verifyCode(req, res, next) {
  try {
    const { code } = req.body;
    console.log(`[Institutions] Verification attempt for code: ${code}`);
    if (!code) return res.status(400).json({ error: 'code required' });
    const institution = await prisma.institution.findFirst({
      where: { eternia_code_hash: code, is_active: true },
      select: { id: true, name: true, plan_type: true }
    });
    
    if (!institution) {
      console.log(`[Institutions] Invalid code: ${code}`);
      return res.status(404).json({ error: 'Invalid institution code' });
    }
    
    console.log(`[Institutions] Verified successfully: ${institution.name}`);
    res.json({ institution });
  } catch (err) { 
    console.error(`[Institutions] Error during verification:`, err);
    next(err); 
  }
}

module.exports = { getInstitutions, getInstitutionById, verifyCode };
