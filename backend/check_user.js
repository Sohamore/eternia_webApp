const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const drSoham = await prisma.profile.findFirst({
    where: { username: 'dr_soham' }
  });
  console.log("dr_soham profile:", JSON.stringify(drSoham, null, 2));

  const allExperts = await prisma.profile.findMany({
    where: { role: 'expert' }
  });
  console.log("All Experts:", JSON.stringify(allExperts.map(e => ({ id: e.id, username: e.username, name: e.name, role: e.role, is_active: e.is_active })), null, 2));

  const allAppointments = await prisma.appointment.findMany({
    orderBy: { created_at: 'desc' }
  });
  console.log("All Appointments in DB:", JSON.stringify(allAppointments, null, 2));
}

main()
  .catch(e => console.error(e))
  .finally(() => prisma.$disconnect());


