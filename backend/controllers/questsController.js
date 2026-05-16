const questsService = require('../services/questsService');
const prisma = require('../prisma/client');

async function getQuests(req, res, next) {
  try {
    const quests = await questsService.getQuests();
    res.json({ quests });
  } catch (err) { next(err); }
}

async function getTodayCompletions(req, res, next) {
  try {
    const completions = await questsService.getTodayCompletions(req.user.id);
    res.json({ completions });
  } catch (err) { next(err); }
}

async function completeQuest(req, res, next) {
  try {
    const { quest_id, answer } = req.body;
    if (!quest_id) return res.status(400).json({ error: 'quest_id required' });
    const result = await questsService.completeQuest(req.user.id, quest_id, answer);
    res.status(201).json(result);
  } catch (err) { next(err); }
}

// Admin endpoints
async function getAllQuestsAdmin(req, res, next) {
  try {
    const quests = await prisma.questCard.findMany({
      orderBy: { created_at: 'desc' }
    });
    res.json({ quests });
  } catch (err) { next(err); }
}

async function getAllCompletionsAdmin(req, res, next) {
  try {
    const completions = await prisma.questCompletion.findMany({
      orderBy: { completed_at: 'desc' },
      take: 200,
      include: {
        user: { select: { id: true, username: true } },
        quest: { select: { id: true, title: true } }
      }
    });
    res.json({ completions });
  } catch (err) { next(err); }
}

async function createQuest(req, res, next) {
  try {
    const { title, description, xp_reward, category } = req.body;
    if (!title || !description) return res.status(400).json({ error: 'title and description required' });
    const quest = await prisma.questCard.create({
      data: {
        title: title.trim(),
        description: description.trim(),
        xp_reward: parseInt(xp_reward) || 10,
        category: category?.trim() || null,
        is_active: true,
      }
    });
    res.status(201).json({ quest });
  } catch (err) { next(err); }
}

async function updateQuest(req, res, next) {
  try {
    const { title, description, xp_reward, category, is_active } = req.body;
    const quest = await prisma.questCard.update({
      where: { id: req.params.id },
      data: {
        ...(title !== undefined && { title: title.trim() }),
        ...(description !== undefined && { description: description.trim() }),
        ...(xp_reward !== undefined && { xp_reward: parseInt(xp_reward) || 10 }),
        ...(category !== undefined && { category: category?.trim() || null }),
        ...(is_active !== undefined && { is_active }),
      }
    });
    res.json({ quest });
  } catch (err) { next(err); }
}

async function deleteQuest(req, res, next) {
  try {
    await prisma.questCard.delete({ where: { id: req.params.id } });
    res.json({ success: true });
  } catch (err) { next(err); }
}

module.exports = {
  getQuests, getTodayCompletions, completeQuest,
  getAllQuestsAdmin, getAllCompletionsAdmin, createQuest, updateQuest, deleteQuest
};
