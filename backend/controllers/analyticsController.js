const prisma = require('../prisma/client');

async function trackEvent(req, res, next) {
  try {
    const { session_hash, event_type, page_path, referrer, user_agent, screen_size } = req.body;
    if (!session_hash || !page_path) return res.status(400).json({ error: 'session_hash and page_path required' });

    await prisma.analyticsEvent.create({
      data: {
        user_id: req.user?.id || null,
        session_hash,
        event_type: event_type || 'page_view',
        page_path,
        referrer: referrer || null,
        user_agent: user_agent || null,
        screen_size: screen_size || null,
      }
    });
    res.status(201).json({ success: true });
  } catch (err) { next(err); }
}

async function getAnalyticsData(req, res, next) {
  try {
    const { start_date, end_date } = req.query;
    const where = {};
    if (start_date) where.created_at = { gte: new Date(start_date) };
    if (end_date) {
      where.created_at = { ...where.created_at, lte: new Date(end_date) };
    }

    // Paginated fetch
    const events = await prisma.analyticsEvent.findMany({
      where,
      orderBy: { created_at: 'desc' },
      take: 5000,
    });

    res.json({ events });
  } catch (err) { next(err); }
}

module.exports = { trackEvent, getAnalyticsData };
