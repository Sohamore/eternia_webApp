const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const institutions = await prisma.institution.findMany();
  console.log('Institutions found:', JSON.stringify(institutions, null, 2));
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
