const logger = require('../utils/logger');

function errorHandler(err, req, res, next) {
  logger.error('Unhandled error:', {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  if (err.code === 'P2002') {
    return res.status(409).json({ error: 'Resource already exists', field: err.meta?.target });
  }
  if (err.code === 'P2025') {
    return res.status(404).json({ error: 'Resource not found' });
  }
  if (err.code === 'P2003') {
    return res.status(400).json({ error: 'Invalid reference - related record not found' });
  }

  const status = err.status || err.statusCode || 500;
  const message = err.message || 'Internal server error';

  // For client errors (4xx), always show the real message
  if (status >= 400 && status < 500) {
    return res.status(status).json({ error: message });
  }

  res.status(status).json({
    error: process.env.NODE_ENV === 'production' ? 'Internal server error' : message,
  });
}

function notFound(req, res) {
  res.status(404).json({ error: `Route ${req.method} ${req.path} not found` });
}

module.exports = { errorHandler, notFound };
