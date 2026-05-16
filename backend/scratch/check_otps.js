const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkOTP() {
  const codes = await prisma.verificationCode.findMany({
    orderBy: { created_at: 'desc' },
    take: 5
  });
  console.log('Recent OTPs:');
  console.log(JSON.stringify(codes, null, 2));
}

checkOTP().finally(() => prisma.$disconnect());
