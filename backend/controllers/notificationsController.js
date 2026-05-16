const notificationsService = require('../services/notificationsService');

async function getNotifications(req, res, next) {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const notifications = await notificationsService.getNotifications(req.user.id, limit);
    res.json({ notifications });
  } catch (err) { next(err); }
}

async function markAsRead(req, res, next) {
  try {
    const notification = await notificationsService.markAsRead(req.user.id, req.params.id);
    res.json({ notification });
  } catch (err) { next(err); }
}

async function markAllAsRead(req, res, next) {
  try {
    const result = await notificationsService.markAllAsRead(req.user.id);
    res.json(result);
  } catch (err) { next(err); }
}

module.exports = { getNotifications, markAsRead, markAllAsRead };
