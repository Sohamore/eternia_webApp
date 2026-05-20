const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const profile = await prisma.profile.findFirst({
    where: { username: { contains: 'soham', mode: 'insensitive' } }
  });
  console.log("Profile for dr_soham / soham:", JSON.stringify(profile, null, 2));

  const allExperts = await prisma.profile.findMany({
    where: { role: 'expert' }
  });
  console.log("All Experts in DB:", JSON.stringify(allExperts.map(e => ({ id: e.id, username: e.username, role: e.role })), null, 2));
  
  const allAppointments = await prisma.appointment.findMany({
    orderBy: { created_at: 'desc' },
    take: 5,
    include: {
      expert: { select: { username: true } },
      student: { select: { username: true } }
    }
  });
  console.log("Latest Appointments in DB:", JSON.stringify(allAppointments, null, 2));
}

main()
  .catch(e => console.error(e))
  .finally(() => prisma.$disconnect());
