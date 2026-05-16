const prisma = require('../prisma/client');

// Gratitude
async function getGratitude(req, res, next) {
  try {
    const entries = await prisma.gratitudeEntry.findMany({
      where: { user_id: req.user.id },
      orderBy: { created_at: 'desc' },
      take: 30,
    });
    res.json({ entries });
  } catch (err) { next(err); }
}

async function addGratitude(req, res, next) {
  try {
    const { entry_1, entry_2, entry_3 } = req.body;
    if (!entry_1) return res.status(400).json({ error: 'entry_1 required' });
    const entry = await prisma.gratitudeEntry.create({
      data: { user_id: req.user.id, entry_1, entry_2: entry_2 || null, entry_3: entry_3 || null }
    });
    res.status(201).json({ entry });
  } catch (err) { next(err); }
}

// Journal
async function getJournal(req, res, next) {
  try {
    const entries = await prisma.journalEntry.findMany({
      where: { user_id: req.user.id },
      orderBy: { created_at: 'desc' },
      take: 50,
    });
    res.json({ entries });
  } catch (err) { next(err); }
}

async function addJournalEntry(req, res, next) {
  try {
    const { title, content, mood_tag } = req.body;
    if (!content) return res.status(400).json({ error: 'content required' });
    const entry = await prisma.journalEntry.create({
      data: { user_id: req.user.id, title: title || null, content, mood_tag: mood_tag || null }
    });
    res.status(201).json({ entry });
  } catch (err) { next(err); }
}

async function deleteJournalEntry(req, res, next) {
  try {
    const entry = await prisma.journalEntry.findFirst({
      where: { id: req.params.id, user_id: req.user.id }
    });
    if (!entry) return res.status(404).json({ error: 'Entry not found' });
    await prisma.journalEntry.delete({ where: { id: req.params.id } });
    res.json({ success: true });
  } catch (err) { next(err); }
}

// Mood
async function getMood(req, res, next) {
  try {
    const entries = await prisma.moodEntry.findMany({
      where: { user_id: req.user.id },
      orderBy: { created_at: 'desc' },
      take: 30,
    });
    res.json({ entries });
  } catch (err) { next(err); }
}

async function addMoodEntry(req, res, next) {
  try {
    const { mood, note } = req.body;
    if (mood === undefined || mood === null) return res.status(400).json({ error: 'mood required' });
    const entry = await prisma.moodEntry.create({
      data: { user_id: req.user.id, mood: parseInt(mood), note: note || null }
    });
    res.status(201).json({ entry });
  } catch (err) { next(err); }
}

module.exports = { getGratitude, addGratitude, getJournal, addJournalEntry, deleteJournalEntry, getMood, addMoodEntry };
