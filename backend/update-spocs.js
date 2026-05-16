const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

async function updateSpoc(username, password) {
  const email = `${username.toLowerCase()}@eternia.local`;
  const password_hash = await bcrypt.hash(password, 12);

  try {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      console.log(`User ${username} not found.`);
      return;
    }

    await prisma.user.update({
      where: { id: user.id },
      data: { password_hash }
    });

    await prisma.profile.update({
      where: { id: user.id },
      data: { role: 'spoc', is_active: true }
    });

    console.log(`SPOC ${username} updated successfully with password: ${password}`);
  } catch (error) {
    console.error(`Error updating SPOC ${username}:`, error);
  }
}

async function main() {
  await updateSpoc('dr_sejal', 'admin123');
  await updateSpoc('spoc_remo123', 'admin123');
}

main()
  .catch(e => console.error(e))
  .finally(async () => await prisma.$disconnect());
