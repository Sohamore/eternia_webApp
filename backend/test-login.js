const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

async function testLogin(username, password) {
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
    console.log(`User ${username} not found.`);
    return;
  }

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    console.log(`Invalid password for ${username}.`);
  } else {
    const profile = await prisma.profile.findUnique({ where: { id: user.id } });
    console.log(`Login successful for ${username}! Role: ${profile.role}, IsActive: ${profile.is_active}`);
  }
}

async function main() {
  console.log("Testing Admin login:");
  await testLogin('admin', 'admin123');
  
  console.log("\nTesting SPOC login (dr_sejal):");
  await testLogin('dr_sejal', 'admin123'); // Guessing password or looking for others
  
  console.log("\nTesting SPOC login (spoc_remo123):");
  await testLogin('spoc_remo123', 'admin123');
}

main()
  .catch(e => console.error(e))
  .finally(async () => await prisma.$disconnect());
