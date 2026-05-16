const prisma = require('../prisma/client');

async function getSounds(req, res, next) {
  try {
    const sounds = await prisma.soundContent.findMany({
      where: { is_active: true },
      orderBy: { play_count: 'desc' }
    });
    res.json({ sounds });
  } catch (err) { next(err); }
}

async function getAllSoundsAdmin(req, res, next) {
  try {
    const sounds = await prisma.soundContent.findMany({
      orderBy: { created_at: 'desc' }
    });
    res.json({ sounds });
  } catch (err) { next(err); }
}

async function createSound(req, res, next) {
  try {
    const { title, artist, category, description, duration_sec, cover_emoji, file_url } = req.body;
    if (!title) return res.status(400).json({ error: 'title is required' });
    const sound = await prisma.soundContent.create({
      data: {
        title,
        artist: artist || null,
        category: category || 'meditation',
        description: description || null,
        duration_sec: duration_sec ? parseInt(duration_sec) : null,
        cover_emoji: cover_emoji || null,
        file_url: file_url || null,
        is_active: true,
      }
    });
    res.status(201).json({ sound });
  } catch (err) { next(err); }
}

async function updateSound(req, res, next) {
  try {
    const { title, artist, category, description, duration_sec, cover_emoji, file_url, is_active } = req.body;
    const sound = await prisma.soundContent.update({
      where: { id: req.params.id },
      data: {
        ...(title !== undefined && { title }),
        ...(artist !== undefined && { artist }),
        ...(category !== undefined && { category }),
        ...(description !== undefined && { description }),
        ...(duration_sec !== undefined && { duration_sec: duration_sec ? parseInt(duration_sec) : null }),
        ...(cover_emoji !== undefined && { cover_emoji }),
        ...(file_url !== undefined && { file_url }),
        ...(is_active !== undefined && { is_active }),
      }
    });
    res.json({ sound });
  } catch (err) { next(err); }
}

async function deleteSound(req, res, next) {
  try {
    await prisma.soundContent.delete({ where: { id: req.params.id } });
    res.json({ success: true });
  } catch (err) { next(err); }
}

module.exports = { getSounds, getAllSoundsAdmin, createSound, updateSound, deleteSound };
