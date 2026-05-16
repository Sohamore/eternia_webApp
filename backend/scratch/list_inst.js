const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const institutions = await prisma.institution.findMany();
  console.log(JSON.stringify(institutions, null, 2));
}

main().catch(console.error).finally(() => prisma.$disconnect());
