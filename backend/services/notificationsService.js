const prisma = require('../prisma/client');

async function getNotifications(userId, limit = 50) {
  return prisma.notification.findMany({
    where: { user_id: userId },
    orderBy: { created_at: 'desc' },
    take: limit,
  });
}

async function markAsRead(userId, notificationId) {
  const notif = await prisma.notification.findFirst({
    where: { id: notificationId, user_id: userId }
  });
  if (!notif) throw Object.assign(new Error('Notification not found'), { status: 404 });
  return prisma.notification.update({
    where: { id: notificationId },
    data: { is_read: true }
  });
}

async function markAllAsRead(userId) {
  await prisma.notification.updateMany({
    where: { user_id: userId, is_read: false },
    data: { is_read: true }
  });
  return { success: true };
}

async function createNotification(userId, type, title, message, metadata) {
  return prisma.notification.create({
    data: { user_id: userId, type, title, message: message || null, metadata: metadata || null }
  });
}

module.exports = { getNotifications, markAsRead, markAllAsRead, createNotification };
