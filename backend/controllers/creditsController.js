const creditsService = require('../services/creditsService');

async function getBalance(req, res, next) {
  try {
    const balance = await creditsService.getBalance(req.user.id);
    res.json({ balance });
  } catch (err) { next(err); }
}

async function getWeeklyEarnTotal(req, res, next) {
  try {
    const total = await creditsService.getWeeklyEarnTotal(req.user.id);
    res.json({ total });
  } catch (err) { next(err); }
}

async function getTransactions(req, res, next) {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const txs = await creditsService.getTransactions(req.user.id, limit);
    res.json({ transactions: txs });
  } catch (err) { next(err); }
}

async function earnCredits(req, res, next) {
  try {
    const { amount, notes, reference_id } = req.body;
    if (!amount || amount < 1) return res.status(400).json({ error: 'Invalid amount' });
    const result = await creditsService.earnCredits(req.user.id, amount, notes, reference_id);
    res.json(result);
  } catch (err) { next(err); }
}

async function spendCredits(req, res, next) {
  try {
    const { amount, notes, reference_id } = req.body;
    if (!amount || amount < 1 || amount > 500) return res.status(400).json({ error: 'Amount must be 1-500' });
    const result = await creditsService.spendCreditsAtomic(req.user.id, amount, notes, reference_id);
    if (!result.success) return res.status(402).json({ error: 'Insufficient credits', ...result });
    res.json(result);
  } catch (err) { next(err); }
}

async function grantCredits(req, res, next) {
  try {
    const { username, amount, institution_id } = req.body;
    if (!username || !amount) return res.status(400).json({ error: 'username and amount required' });
    const result = await creditsService.grantCredits(req.user.id, req.user.role, username, amount, institution_id);
    res.json(result);
  } catch (err) { next(err); }
}

async function createOrder(req, res, next) {
  try {
    const { credits } = req.body;
    if (!credits) return res.status(400).json({ error: 'credits required' });
    const result = await creditsService.createRazorpayOrder(req.user.id, credits);
    res.json(result);
  } catch (err) { next(err); }
}

async function verifyPayment(req, res, next) {
  try {
    const { razorpay_payment_id, razorpay_order_id, razorpay_signature } = req.body;
    if (!razorpay_payment_id || !razorpay_order_id || !razorpay_signature) {
      return res.status(400).json({ error: 'Payment verification fields required' });
    }
    const result = await creditsService.verifyRazorpayPayment(
      req.user.id, razorpay_payment_id, razorpay_order_id, razorpay_signature
    );
    res.json(result);
  } catch (err) { next(err); }
}

module.exports = { getBalance, getWeeklyEarnTotal, getTransactions, earnCredits, spendCredits, grantCredits, createOrder, verifyPayment };
