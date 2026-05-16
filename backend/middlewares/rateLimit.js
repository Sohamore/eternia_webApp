const rateLimit = require('express-rate-limit');

function createRateLimit(windowMs, max, message) {
  return rateLimit({
    windowMs,
    max,
    message: { error: message || 'Too many requests, please try again later' },
    standardHeaders: true,
    legacyHeaders: false,
  });
}

const authLimiter = createRateLimit(15 * 60 * 1000, 20, 'Too many auth attempts');
const creditsLimiter = createRateLimit(60 * 1000, 20, 'Too many credit requests');
const strictLimiter = createRateLimit(60 * 1000, 10, 'Rate limit exceeded');
const generalLimiter = createRateLimit(60 * 1000, 60, 'Too many requests');
const aiLimiter = createRateLimit(60 * 1000, 30, 'AI rate limit exceeded');

module.exports = { authLimiter, creditsLimiter, strictLimiter, generalLimiter, aiLimiter };
