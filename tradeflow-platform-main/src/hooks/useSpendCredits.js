import api from "@/lib/api";

/**
 * Spend ECC credits atomically. Used by appointments, blackbox and peer sessions.
 * @returns {{ success, source, remaining } | throws}
 */
export async function spendCredits(amount, notes, referenceId) {
  try {
    const { data } = await api.post('/credits/spend', {
      amount,
      notes: notes || null,
      reference_id: referenceId || null,
    });
    return data;
  } catch (err) {
    const msg = err.response?.data?.error || 'Failed to spend credits';
    throw new Error(msg);
  }
}
