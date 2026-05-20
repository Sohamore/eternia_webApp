require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

async function main() {
  const hash = await bcrypt.hash('admin123', 12);
  const result = await prisma.user.updateMany({
    where: { email: 'dr_sejal_expert@eternia.local' },
    data: { password_hash: hash }
  });
  console.log('Updated:', result.count, 'user(s)');
  console.log('Username: dr_sejal_expert');
  console.log('Password: admin123');
  await prisma.$disconnect();
}

main().catch(e => { console.error(e); process.exit(1); });
