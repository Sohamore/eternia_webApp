const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const studentId = '92a7520a-8458-4741-bf55-0748bdb1f70c'; // From existing appointment
  const expertId = 'e10b5feb-1354-4a2e-8091-ce6cfffc78c5';   // dr_soham

  console.log("Testing slotless appointment creation via Prisma...");
  try {
    const appointment = await prisma.appointment.create({
      data: {
        student_id: studentId,
        expert_id: expertId,
        slot_id: null,
        slot_time: new Date(),
        session_type: 'video',
        credits_charged: 0,
        status: 'pending',
        room_id: 'test-room-12345',
      }
    });
    console.log("SUCCESS! Appointment created:", JSON.stringify(appointment, null, 2));

    // Clean it up so we don't leave junk data
    await prisma.appointment.delete({
      where: { id: appointment.id }
    });
    console.log("Cleaned up test appointment successfully.");
  } catch (err) {
    console.error("FAILED to create appointment in database:", err);
  }
}

main()
  .catch(e => console.error(e))
  .finally(() => prisma.$disconnect());
