const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('Seeding test data...');
  try {
    const inst = await prisma.institution.findFirst();
    if (!inst) {
      console.log('No institution found');
      return;
    }

    let expertUser = await prisma.user.findFirst({
      where: { email: 'dr_sejal_expert@eternia.local' }
    });

    if (!expertUser) {
      expertUser = await prisma.user.create({
        data: {
          email: 'dr_sejal_expert@eternia.local',
          password_hash: '$2a$12$ignored_hash',
        }
      });
      
      await prisma.profile.create({
        data: {
          id: expertUser.id,
          username: 'dr_sejal_expert',
          role: 'expert',
          institution_id: inst.id,
          specialty: 'Clinical Psychologist',
          is_active: true
        }
      });
    }

    const expertId = expertUser.id;

    await prisma.expertAvailability.createMany({
      data: [
        {
          expert_id: expertId,
          institution_id: inst.id,
          start_time: new Date(Date.now() + 3600000),
          end_time: new Date(Date.now() + 7200000)
        },
        {
          expert_id: expertId,
          institution_id: inst.id,
          start_time: new Date(Date.now() + 86400000),
          end_time: new Date(Date.now() + 90000000)
        }
      ],
      skipDuplicates: true
    });

    await prisma.soundContent.createMany({
      data: [
        {
          title: 'Ocean Waves',
          category: 'nature',
          file_url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          duration_sec: 300,
          cover_emoji: '🌊'
        },
        {
          title: 'Deep Focus',
          category: 'lofi',
          file_url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
          duration_sec: 450,
          cover_emoji: '🎧'
        }
      ],
      skipDuplicates: true
    });

    await prisma.questCard.createMany({
      data: [
        {
          title: 'Breathing Exercise',
          description: 'Take 5 deep breaths and describe how you feel.',
          xp_reward: 20,
          category: 'mindfulness'
        },
        {
          title: 'Daily Gratitude',
          description: 'Write down 3 things you are grateful for today.',
          xp_reward: 30,
          category: 'gratitude'
        }
      ],
      skipDuplicates: true
    });

    console.log('Seeding complete!');
  } catch (err) {
    console.error(err);
  } finally {
    await prisma.$disconnect();
  }
}

main();
