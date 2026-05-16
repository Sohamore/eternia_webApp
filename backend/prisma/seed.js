const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // Seed quest cards
  await prisma.questCard.createMany({
    data: [
      { title: 'Morning Mindfulness', description: 'Spend 5 minutes on mindful breathing before starting your day.', xp_reward: 10, category: 'mindfulness' },
      { title: 'Gratitude Journal', description: 'Write down 3 things you are grateful for today.', xp_reward: 10, category: 'journaling' },
      { title: 'Physical Movement', description: 'Do 10 minutes of any physical exercise or stretching.', xp_reward: 15, category: 'wellness' },
      { title: 'Digital Detox', description: 'Spend 30 minutes away from all screens.', xp_reward: 20, category: 'wellness' },
      { title: 'Connect with Nature', description: 'Spend 15 minutes outdoors or near natural light.', xp_reward: 10, category: 'wellness' },
      { title: 'Acts of Kindness', description: 'Perform one act of kindness for someone today.', xp_reward: 15, category: 'social' },
      { title: 'Deep Breathing', description: 'Practice box breathing: 4 counts in, 4 hold, 4 out, 4 hold. Repeat 5 times.', xp_reward: 10, category: 'mindfulness' },
      { title: 'Mood Check-in', description: 'Log your mood and reflect on what influenced it today.', xp_reward: 5, category: 'awareness' },
    ],
    skipDuplicates: true,
  });

  // Seed sound content
  await prisma.soundContent.createMany({
    data: [
      { title: 'Ocean Waves', artist: 'Nature Sounds', category: 'nature', description: 'Calming ocean wave sounds', cover_emoji: '🌊', duration_sec: 600 },
      { title: 'Forest Rain', artist: 'Nature Sounds', category: 'nature', description: 'Gentle rain in a forest', cover_emoji: '🌧️', duration_sec: 900 },
      { title: 'Tibetan Singing Bowl', artist: 'Meditation Masters', category: 'meditation', description: 'Traditional Tibetan bowl sounds', cover_emoji: '🔔', duration_sec: 480 },
      { title: 'Morning Birds', artist: 'Nature Sounds', category: 'nature', description: 'Peaceful birdsong at dawn', cover_emoji: '🐦', duration_sec: 720 },
      { title: 'White Noise', artist: 'Sleep Sounds', category: 'sleep', description: 'Pure white noise for focus and sleep', cover_emoji: '💨', duration_sec: 1800 },
      { title: 'Calm Piano', artist: 'Ambient Music', category: 'music', description: 'Soft piano melodies for relaxation', cover_emoji: '🎹', duration_sec: 540 },
    ],
    skipDuplicates: true,
  });

  console.log('Database seeded successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
