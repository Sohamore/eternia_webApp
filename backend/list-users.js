const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    include: {
      profile: true,
    }
  });

  console.log("Users and Profiles:");
  users.forEach(u => {
    console.log(`ID: ${u.id}, Email: ${u.email}, Role: ${u.profile?.role}, IsActive: ${u.profile?.is_active}`);
  });
}

main()
  .catch(e => console.error(e))
  .finally(async () => await prisma.$disconnect());
