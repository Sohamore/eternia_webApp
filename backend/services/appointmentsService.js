const prisma = require('../prisma/client');

async function getExperts(institutionId) {
  const where = { role: 'expert', is_active: true };
  if (institutionId) where.institution_id = institutionId;
  return prisma.profile.findMany({
    where,
    select: { id: true, username: true, specialty: true, avatar_url: true, bio: true, total_sessions: true }
  });
}

async function getAvailableSlots(expertId) {
  const now = new Date();
  return prisma.expertAvailability.findMany({
    where: {
      expert_id: expertId || undefined,
      is_booked: false,
      start_time: { gt: now }
    },
    include: {
      expert: { select: { id: true, username: true, specialty: true } }
    },
    orderBy: { start_time: 'asc' }
  });
}

async function getMySlots(expertId) {
  return prisma.expertAvailability.findMany({
    where: { expert_id: expertId },
    orderBy: { start_time: 'asc' }
  });
}

async function getUserAppointments(userId, role) {
  const where = role === 'expert' ? { expert_id: userId } : { student_id: userId };
  return prisma.appointment.findMany({
    where,
    include: {
      expert: { select: { id: true, username: true, specialty: true, avatar_url: true } },
      student: { select: { id: true, username: true } }
    },
    orderBy: { slot_time: 'desc' },
    take: 50,
  });
}

async function createAppointment(studentId, expertId, slotId, slotTime, sessionType, creditsCharged) {
  // Verify slot availability
  if (slotId) {
    const slot = await prisma.expertAvailability.findFirst({
      where: { id: slotId, is_booked: false }
    });
    if (!slot) throw Object.assign(new Error('Slot no longer available'), { status: 409 });
  }

  return prisma.$transaction(async (tx) => {
    const appointment = await tx.appointment.create({
      data: {
        student_id: studentId,
        expert_id: expertId,
        slot_id: slotId || null,
        slot_time: new Date(slotTime),
        session_type: sessionType || 'video',
        credits_charged: creditsCharged || 0,
        status: 'pending',
      },
      include: {
        expert: { select: { id: true, username: true, specialty: true } }
      }
    });

    if (slotId) {
      await tx.expertAvailability.update({
        where: { id: slotId },
        data: { is_booked: true }
      });
    }

    return appointment;
  });
}

async function cancelAppointment(userId, appointmentId) {
  const appointment = await prisma.appointment.findFirst({
    where: {
      id: appointmentId,
      OR: [{ student_id: userId }, { expert_id: userId }]
    }
  });
  if (!appointment) throw Object.assign(new Error('Appointment not found'), { status: 404 });
  if (appointment.status === 'completed' || appointment.status === 'cancelled') {
    throw Object.assign(new Error('Cannot cancel this appointment'), { status: 400 });
  }

  await prisma.appointment.update({
    where: { id: appointmentId },
    data: { status: 'cancelled', updated_at: new Date() }
  });

  // Refund if credits were charged and slot not yet started
  if (appointment.credits_charged > 0 && appointment.student_id === userId) {
    const spendTx = await prisma.creditTransaction.findFirst({
      where: { reference_id: appointmentId, type: 'spend' }
    });
    if (spendTx) {
      const existingRefund = await prisma.creditTransaction.findFirst({
        where: { reference_id: appointmentId, type: 'grant' }
      });
      if (!existingRefund) {
        await prisma.creditTransaction.create({
          data: {
            user_id: appointment.student_id,
            delta: Math.abs(spendTx.delta),
            type: 'grant',
            notes: 'Appointment cancelled — refund',
            reference_id: appointmentId,
          }
        });
      }
    }
  }

  // Free up slot
  if (appointment.slot_id) {
    await prisma.expertAvailability.update({
      where: { id: appointment.slot_id },
      data: { is_booked: false }
    });
  }

  return { success: true };
}

async function addAvailabilitySlot(expertId, startTime, endTime, recurrenceRule, institutionId) {
  return prisma.expertAvailability.create({
    data: {
      expert_id: expertId,
      start_time: new Date(startTime),
      end_time: new Date(endTime),
      recurrence_rule: recurrenceRule || null,
      institution_id: institutionId || null
    }
  });
}

async function deleteAvailabilitySlot(expertId, slotId) {
  const slot = await prisma.expertAvailability.findFirst({
    where: { id: slotId, expert_id: expertId, is_booked: false }
  });
  if (!slot) throw Object.assign(new Error('Slot not found or already booked'), { status: 404 });
  await prisma.expertAvailability.delete({ where: { id: slotId } });
  return { success: true };
}

async function completeAppointment(expertId, appointmentId, notes) {
  const appointment = await prisma.appointment.findFirst({
    where: { id: appointmentId, expert_id: expertId }
  });
  if (!appointment) throw Object.assign(new Error('Appointment not found'), { status: 404 });

  await prisma.appointment.update({
    where: { id: appointmentId },
    data: {
      status: 'completed',
      completed_at: new Date(),
      session_notes_encrypted: notes || null
    }
  });

  return { success: true };
}

async function rescheduleAppointment(expertId, appointmentId, newSlotId, rescheduleReason) {
  const appointment = await prisma.appointment.findFirst({
    where: { id: appointmentId, expert_id: expertId },
    include: { expert: true }
  });
  if (!appointment) throw Object.assign(new Error('Appointment not found'), { status: 404 });

  const newSlot = await prisma.expertAvailability.findFirst({
    where: { id: newSlotId, is_booked: false }
  });
  if (!newSlot) throw Object.assign(new Error('New slot not found or already booked'), { status: 404 });

  return prisma.$transaction(async (tx) => {
    const oldTime = appointment.slot_time;

    // Update the appointment
    const updated = await tx.appointment.update({
      where: { id: appointmentId },
      data: {
        slot_time: newSlot.start_time,
        slot_id: newSlot.id,
        rescheduled_from: oldTime,
        rescheduled_by: expertId,
        reschedule_reason: rescheduleReason,
        updated_at: new Date()
      }
    });

    // Mark new slot as booked
    await tx.expertAvailability.update({
      where: { id: newSlot.id },
      data: { is_booked: true }
    });

    // Free up old slot if it exists
    if (appointment.slot_id) {
      await tx.expertAvailability.update({
        where: { id: appointment.slot_id },
        data: { is_booked: false }
      });
    }

    // Create notification
    await tx.notification.create({
      data: {
        user_id: appointment.student_id,
        type: 'reschedule',
        title: 'Appointment Rescheduled',
        message: `Dr. ${appointment.expert?.username || "Expert"} rescheduled your appointment. Reason: ${rescheduleReason}`,
        metadata: {
          appointment_id: appointmentId,
          old_time: oldTime.toISOString(),
          new_time: newSlot.start_time.toISOString(),
          expert_name: appointment.expert?.username,
          reason: rescheduleReason
        }
      }
    });

    return updated;
  });
}

async function escalateAppointment(expertId, appointmentId, reason, transcriptSnippet) {
  const appointment = await prisma.appointment.findFirst({
    where: { id: appointmentId, expert_id: expertId },
    include: { student: true }
  });
  if (!appointment) throw Object.assign(new Error('Appointment not found'), { status: 404 });

  // Add audit log
  await prisma.auditLog.create({
    data: {
      actor_id: expertId,
      action_type: 'appointment_escalated',
      target_table: 'appointments',
      target_id: appointmentId,
      metadata: { reason, transcriptSnippet }
    }
  });

  // Fetch student's emergency contact
  const userPrivate = await prisma.userPrivate.findUnique({
    where: { id: appointment.student_id }
  });

  let contact = null;
  if (userPrivate && userPrivate.emergency_name_encrypted) {
    contact = {
      name: userPrivate.emergency_name_encrypted,
      phone: userPrivate.emergency_phone_encrypted
    };
  }

  return { success: true, contact };
}

module.exports = {
  getExperts, getAvailableSlots, getMySlots, getUserAppointments,
  createAppointment, cancelAppointment, addAvailabilitySlot, deleteAvailabilitySlot,
  completeAppointment, rescheduleAppointment, escalateAppointment
};
