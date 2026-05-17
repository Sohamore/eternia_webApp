const prisma = require("../prisma/client");

const WEEKLY_EARN_CAP = 50;

async function getQuests() {
  return prisma.questCard.findMany({
    where: { is_active: true },
    orderBy: { xp_reward: "asc" },
  });
}

async function getTodayCompletions(userId) {
  const startOfDay = new Date();
  startOfDay.setHours(0, 0, 0, 0);
  const endOfDay = new Date();
  endOfDay.setHours(23, 59, 59, 999);

  return prisma.questCompletion.findMany({
    where: {
      user_id: userId,
      completed_at: { gte: startOfDay, lte: endOfDay },
    },
  });
}

async function completeQuest(userId, questId) {
  // Check not already completed today
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const existing = await prisma.questCompletion.findFirst({
    where: {
      user_id: userId,
      quest_id: questId,
      completed_at: { gte: today },
    },
  });
  if (existing)
    throw Object.assign(new Error("Quest already completed today"), {
      status: 409,
    });

  const quest = await prisma.questCard.findUnique({ where: { id: questId } });
  if (!quest || !quest.is_active)
    throw Object.assign(new Error("Quest not found"), { status: 404 });

  // Check weekly ECC cap
  const now = new Date();
  const dayOfWeek = now.getDay();
  const startOfWeek = new Date(now);
  startOfWeek.setDate(now.getDate() - (dayOfWeek === 0 ? 6 : dayOfWeek - 1));
  startOfWeek.setHours(0, 0, 0, 0);

  const weeklyAgg = await prisma.creditTransaction.aggregate({
    where: { user_id: userId, type: "earn", created_at: { gte: startOfWeek } },
    _sum: { delta: true },
  });
  const weeklyTotal = weeklyAgg._sum.delta || 0;
  const remaining = Math.max(0, WEEKLY_EARN_CAP - weeklyTotal);
  const actualReward = Math.min(quest.xp_reward, remaining);

  return prisma.$transaction(async (tx) => {
    const completion = await tx.questCompletion.create({
      data: {
        user_id: userId,
        quest_id: questId,
        completed_date: new Date(),
      },
    });

    if (actualReward > 0) {
      await tx.creditTransaction.create({
        data: {
          user_id: userId,
          delta: actualReward,
          type: "earn",
          notes: `Quest completed: ${quest.title}`,
          reference_id: quest.id,
        },
      });
    }

    return {
      completion,
      reward: actualReward,
      weeklyTotal: weeklyTotal + actualReward,
    };
  });
}

module.exports = { getQuests, getTodayCompletions, completeQuest };
