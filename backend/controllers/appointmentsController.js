const appointmentsService = require('../services/appointmentsService');

async function getExperts(req, res, next) {
  try {
    const experts = await appointmentsService.getExperts(req.query.institution_id);
    res.json({ experts });
  } catch (err) { next(err); }
}

async function getSlots(req, res, next) {
  try {
    const slots = await appointmentsService.getAvailableSlots(req.query.expert_id);
    res.json({ slots });
  } catch (err) { next(err); }
}

async function getMySlots(req, res, next) {
  try {
    const slots = await appointmentsService.getMySlots(req.user.id);
    res.json({ slots });
  } catch (err) { next(err); }
}

async function getMyAppointments(req, res, next) {
  try {
    const appointments = await appointmentsService.getUserAppointments(req.user.id, req.user.role);
    res.json({ appointments });
  } catch (err) { next(err); }
}

async function createAppointment(req, res, next) {
  try {
    const { expert_id, slot_id, slot_time, session_type, credits_charged } = req.body;
    if (!expert_id || !slot_time) return res.status(400).json({ error: 'expert_id and slot_time required' });
    const appointment = await appointmentsService.createAppointment(
      req.user.id, expert_id, slot_id, slot_time, session_type, credits_charged
    );
    res.status(201).json({ appointment });
  } catch (err) { next(err); }
}

async function cancelAppointment(req, res, next) {
  try {
    const result = await appointmentsService.cancelAppointment(req.user.id, req.params.id);
    res.json(result);
  } catch (err) { next(err); }
}

async function addSlot(req, res, next) {
  try {
    const { start_time, end_time, recurrence_rule, institution_id } = req.body;
    if (!start_time || !end_time) return res.status(400).json({ error: 'start_time and end_time required' });
    const slot = await appointmentsService.addAvailabilitySlot(req.user.id, start_time, end_time, recurrence_rule, institution_id);
    res.status(201).json({ slot });
  } catch (err) { next(err); }
}

async function deleteSlot(req, res, next) {
  try {
    const result = await appointmentsService.deleteAvailabilitySlot(req.user.id, req.params.id);
    res.json(result);
  } catch (err) { next(err); }
}

async function completeAppointment(req, res, next) {
  try {
    const { notes } = req.body;
    const result = await appointmentsService.completeAppointment(req.user.id, req.params.id, notes);
    res.json(result);
  } catch (err) { next(err); }
}

async function rescheduleAppointment(req, res, next) {
  try {
    const { slot_id, reschedule_reason } = req.body;
    if (!slot_id || !reschedule_reason) return res.status(400).json({ error: 'slot_id and reschedule_reason required' });
    const appointment = await appointmentsService.rescheduleAppointment(req.user.id, req.params.id, slot_id, reschedule_reason);
    res.json({ appointment });
  } catch (err) { next(err); }
}

async function escalateAppointment(req, res, next) {
  try {
    const { justification, transcript_snippet } = req.body;
    const result = await appointmentsService.escalateAppointment(req.user.id, req.params.id, justification, transcript_snippet);
    res.json(result);
  } catch (err) { next(err); }
}

module.exports = { 
  getExperts, getSlots, getMySlots, getMyAppointments, createAppointment, cancelAppointment, 
  addSlot, deleteSlot, completeAppointment, rescheduleAppointment, escalateAppointment
};
