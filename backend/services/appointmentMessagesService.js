const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function getAppointmentMessages(userId, appointmentId) {
  // Validate appointment access
  const appointment = await prisma.appointment.findFirst({
    where: {
      id: appointmentId,
      OR: [
        { student_id: userId },
        { expert_id: userId }
      ]
    }
  });

  if (!appointment) {
    throw Object.assign(new Error('Appointment not found or access denied'), { status: 404 });
  }

  return prisma.appointmentMessage.findMany({
    where: {
      appointment_id: appointmentId
    },
    orderBy: {
      created_at: 'asc'
    }
  });
}

async function sendAppointmentMessage(userId, appointmentId, content) {
  if (!content || content.trim() === '') {
    throw Object.assign(new Error('Message content cannot be empty'), { status: 400 });
  }

  // Validate appointment access and determine sender role
  const appointment = await prisma.appointment.findFirst({
    where: {
      id: appointmentId,
      OR: [
        { student_id: userId },
        { expert_id: userId }
      ]
    }
  });

  if (!appointment) {
    throw Object.assign(new Error('Appointment not found or access denied'), { status: 404 });
  }

  const senderType = (userId === appointment.student_id) ? 'student' : 'expert';

  const message = await prisma.appointmentMessage.create({
    data: {
      appointment_id: appointmentId,
      sender_id: userId,
      sender_type: senderType,
      content: content.trim()
    }
  });

  return message;
}

module.exports = {
  getAppointmentMessages,
  sendAppointmentMessage
};
