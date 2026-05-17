require("dotenv").config({ path: require("path").join(__dirname, "../.env") });
const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Starting production seed...");

  // ================================================================
  // 1. INSTITUTION
  // ================================================================
  let institution = await prisma.institution.findFirst({
    where: { eternia_code_hash: "DEMO2024" },
  });

  if (!institution) {
    institution = await prisma.institution.create({
      data: {
        name: "Demo University",
        eternia_code_hash: "DEMO2024",
        plan_type: "premium",
        credits_pool: 10000,
        is_active: true,
      },
    });
    console.log("✅ Institution created:", institution.name);
  } else {
    console.log("ℹ️  Institution already exists:", institution.name);
  }

  // ================================================================
  // 2. ECC STABILITY POOL
  // ================================================================
  await prisma.eccStabilityPool.upsert({
    where: { institution_id: institution.id },
    update: {},
    create: {
      institution_id: institution.id,
      balance: 5000,
      total_contributed: 5000,
      total_disbursed: 0,
    },
  });
  console.log("✅ ECC Stability Pool ready");

  // ================================================================
  // 3. USERS (Admin, SPOC, Experts, Interns, Students)
  // ================================================================
  const usersToCreate = [
    {
      username: "eternia_admin",
      password: "Admin@2024!",
      role: "admin",
      specialty: null,
      institution_id: null,
    },
    {
      username: "spoc_demo",
      password: "Spoc@2024!",
      role: "spoc",
      specialty: null,
      institution_id: institution.id,
    },
    {
      username: "dr_priya_sharma",
      password: "Expert@2024!",
      role: "expert",
      specialty: "Anxiety & Stress Management",
      institution_id: institution.id,
    },
    {
      username: "dr_arjun_mehta",
      password: "Expert@2024!",
      role: "expert",
      specialty: "Academic Pressure & Focus",
      institution_id: institution.id,
    },
    {
      username: "dr_sneha_kulkarni",
      password: "Expert@2024!",
      role: "expert",
      specialty: "Relationship & Social Anxiety",
      institution_id: institution.id,
    },
    {
      username: "intern_riya",
      password: "Intern@2024!",
      role: "intern",
      specialty: "Peer Support Counselor",
      institution_id: institution.id,
    },
    {
      username: "intern_karan",
      password: "Intern@2024!",
      role: "intern",
      specialty: "Peer Support Counselor",
      institution_id: institution.id,
    },
    {
      username: "therapist_meena",
      password: "Therapist@2024!",
      role: "therapist",
      specialty: "BlackBox Anonymous Therapy",
      institution_id: institution.id,
    },
  ];

  const createdUsers = {};

  for (const u of usersToCreate) {
    // Check if user already exists by username
    const existingProfile = await prisma.profile.findFirst({
      where: { username: u.username },
    });

    if (existingProfile) {
      console.log(`ℹ️  User already exists: ${u.username}`);
      createdUsers[u.username] = existingProfile.id;
      continue;
    }

    const password_hash = await bcrypt.hash(u.password, 12);
    const uniqueTag = require("crypto")
      .randomUUID()
      .replace(/-/g, "")
      .slice(0, 10);
    const email = `${u.username}_${uniqueTag}@eternia.local`;

    const result = await prisma.$transaction(async (tx) => {
      const user = await tx.user.create({ data: { email, password_hash } });

      const profile = await tx.profile.create({
        data: {
          id: user.id,
          username: u.username,
          role: u.role,
          institution_id: u.institution_id,
          specialty: u.specialty,
          is_active: true,
          is_verified: true,
          training_status: u.role === "intern" ? "active" : null,
        },
      });

      await tx.userRole.create({ data: { user_id: user.id, role: u.role } });

      await tx.creditTransaction.create({
        data: {
          user_id: user.id,
          delta: 100,
          type: "grant",
          notes: "Welcome bonus",
        },
      });

      await tx.userPrivate.create({ data: { user_id: user.id } });

      return { user, profile };
    });

    createdUsers[u.username] = result.user.id;
    console.log(`✅ Created user: ${u.username} (${u.role})`);
  }

  // ================================================================
  // 4. EXPERT AVAILABILITY (next 7 days, multiple slots)
  // ================================================================
  const experts = ["dr_priya_sharma", "dr_arjun_mehta", "dr_sneha_kulkarni"];

  for (const expertUsername of experts) {
    const expertId = createdUsers[expertUsername];
    if (!expertId) continue;

    // Check if slots already exist
    const existingSlots = await prisma.expertAvailability.count({
      where: { expert_id: expertId },
    });
    if (existingSlots > 0) continue;

    const slots = [];
    const now = new Date();

    // Create 4 slots per day for next 7 days
    for (let day = 1; day <= 7; day++) {
      const slotHours = [10, 12, 14, 16]; // 10am, 12pm, 2pm, 4pm
      for (const hour of slotHours) {
        const start = new Date(now);
        start.setDate(now.getDate() + day);
        start.setHours(hour, 0, 0, 0);
        const end = new Date(start);
        end.setHours(hour + 1, 0, 0, 0);

        slots.push({
          expert_id: expertId,
          institution_id: institution.id,
          start_time: start,
          end_time: end,
          is_booked: false,
        });
      }
    }

    await prisma.expertAvailability.createMany({
      data: slots,
      skipDuplicates: true,
    });
    console.log(`✅ Created ${slots.length} slots for ${expertUsername}`);
  }

  // ================================================================
  // 5. QUEST CARDS
  // ================================================================
  const quests = [
    {
      title: "Morning Mindfulness",
      description:
        "Spend 5 minutes in silent reflection before your day begins. Notice your thoughts without judgment.",
      xp_reward: 10,
      category: "mindfulness",
    },
    {
      title: "Gratitude Journal",
      description:
        "Write down 3 specific things you are genuinely grateful for today. Be detailed.",
      xp_reward: 10,
      category: "gratitude",
    },
    {
      title: "Deep Breathing",
      description:
        "Practice the 4-7-8 breathing technique for 5 minutes. Inhale 4s, hold 7s, exhale 8s.",
      xp_reward: 10,
      category: "breathing",
    },
    {
      title: "Digital Detox",
      description:
        "Put your phone away for 1 hour and engage in a non-screen activity you enjoy.",
      xp_reward: 15,
      category: "wellness",
    },
    {
      title: "Connect with Nature",
      description:
        "Step outside for at least 15 minutes. Observe the world around you with full attention.",
      xp_reward: 10,
      category: "wellness",
    },
    {
      title: "Random Act of Kindness",
      description:
        "Do something kind for someone today without expecting anything in return.",
      xp_reward: 15,
      category: "social",
    },
    {
      title: "Body Scan Meditation",
      description:
        "Lie down and slowly bring awareness to each part of your body from feet to head.",
      xp_reward: 10,
      category: "mindfulness",
    },
    {
      title: "Evening Reflection",
      description:
        "Before sleeping, write 3 things that went well today and why they happened.",
      xp_reward: 10,
      category: "gratitude",
    },
    {
      title: "Emotion Labeling",
      description:
        "Throughout the day, pause and identify exactly what you are feeling. Name 5 distinct emotions.",
      xp_reward: 15,
      category: "self-awareness",
    },
    {
      title: "Hydration Challenge",
      description:
        "Drink 8 glasses of water today. Notice how your energy and mood change.",
      xp_reward: 5,
      category: "wellness",
    },
    {
      title: "Study Pomodoro",
      description:
        "Use the Pomodoro technique: 25 min focused study, 5 min break, repeat 4 times.",
      xp_reward: 20,
      category: "academic",
    },
    {
      title: "Talk to Someone",
      description:
        "Have a genuine conversation with a friend, family member, or classmate today.",
      xp_reward: 15,
      category: "social",
    },
  ];

  for (const quest of quests) {
    const existing = await prisma.questCard.findFirst({
      where: { title: quest.title },
    });
    if (!existing)
      await prisma.questCard.create({ data: { ...quest, is_active: true } });
  }
  console.log(`✅ ${quests.length} quest cards ready`);

  // ================================================================
  // 6. SOUND CONTENT
  // ================================================================
  const sounds = [
    {
      title: "Ocean Waves",
      artist: "Nature Sounds",
      category: "nature",
      file_url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      duration_sec: 300,
      cover_emoji: "🌊",
    },
    {
      title: "Forest Rain",
      artist: "Nature Sounds",
      category: "nature",
      file_url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
      duration_sec: 420,
      cover_emoji: "🌧️",
    },
    {
      title: "Tibetan Singing Bowl",
      artist: "Healing Sounds",
      category: "meditation",
      file_url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
      duration_sec: 600,
      cover_emoji: "🎵",
    },
    {
      title: "Morning Birds",
      artist: "Nature Sounds",
      category: "nature",
      file_url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
      duration_sec: 360,
      cover_emoji: "🐦",
    },
    {
      title: "White Noise Focus",
      artist: "Focus Lab",
      category: "focus",
      file_url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3",
      duration_sec: 1800,
      cover_emoji: "🎧",
    },
    {
      title: "Calm Piano",
      artist: "Mindful Music",
      category: "instrumental",
      file_url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3",
      duration_sec: 240,
      cover_emoji: "🎹",
    },
    {
      title: "Deep Sleep Waves",
      artist: "Sleep Lab",
      category: "sleep",
      file_url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3",
      duration_sec: 3600,
      cover_emoji: "😴",
    },
    {
      title: "Study Lo-Fi",
      artist: "Lo-Fi Collective",
      category: "lofi",
      file_url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3",
      duration_sec: 5400,
      cover_emoji: "📚",
    },
    {
      title: "Crystal Bowl Healing",
      artist: "Healing Sounds",
      category: "meditation",
      file_url: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3",
      duration_sec: 900,
      cover_emoji: "✨",
    },
    {
      title: "Campfire Crackle",
      artist: "Nature Sounds",
      category: "nature",
      file_url:
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3",
      duration_sec: 600,
      cover_emoji: "🔥",
    },
  ];

  for (const sound of sounds) {
    const existing = await prisma.soundContent.findFirst({
      where: { title: sound.title },
    });
    if (!existing)
      await prisma.soundContent.create({
        data: { ...sound, is_active: true, play_count: 0 },
      });
  }
  console.log(`✅ ${sounds.length} sound tracks ready`);

  // ================================================================
  // 7. TRAINING MODULES (for interns)
  // ================================================================
  const trainingModules = [
    {
      day_number: 1,
      title: "Introduction to Peer Support",
      description:
        "Understanding your role as a peer support intern and the Eternia platform.",
      duration: "45 minutes",
      objectives: [
        "Understand peer support principles",
        "Learn platform guidelines",
        "Review ethics and boundaries",
      ],
      content:
        "Welcome to Eternia Peer Support Training. As a peer supporter, your role is to provide empathetic, non-judgmental support to fellow students...",
      has_quiz: true,
      quiz_questions: JSON.stringify([
        {
          q: "What is the primary goal of peer support?",
          options: [
            "Give advice",
            "Provide empathetic listening",
            "Solve problems",
            "Diagnose issues",
          ],
          correct: 1,
        },
        {
          q: "When should you escalate a session?",
          options: [
            "When bored",
            "When peer mentions self-harm",
            "When session ends",
            "Always",
          ],
          correct: 1,
        },
      ]),
    },
    {
      day_number: 2,
      title: "Active Listening Techniques",
      description:
        "Mastering the art of deep listening and reflective communication.",
      duration: "60 minutes",
      objectives: [
        "Practice active listening",
        "Use reflective statements",
        "Avoid giving unsolicited advice",
      ],
      content:
        "Active listening is the foundation of effective peer support. It involves being fully present, avoiding judgment, and reflecting back what you hear...",
      has_quiz: true,
      quiz_questions: JSON.stringify([
        {
          q: "Active listening means:",
          options: [
            "Planning your response",
            "Being fully present",
            "Giving advice",
            "Taking notes",
          ],
          correct: 1,
        },
      ]),
    },
    {
      day_number: 3,
      title: "Crisis Recognition & Escalation",
      description:
        "Identifying warning signs and knowing when and how to escalate.",
      duration: "90 minutes",
      objectives: [
        "Recognize crisis indicators",
        "Know escalation procedures",
        "Practice de-escalation",
      ],
      content:
        "Crisis recognition is one of the most critical skills in peer support. Warning signs include: expressions of hopelessness, mentions of self-harm...",
      has_quiz: true,
      quiz_questions: JSON.stringify([
        {
          q: "Which is a crisis warning sign?",
          options: [
            "Feeling stressed",
            "Expressing hopelessness",
            "Being tired",
            "Feeling anxious",
          ],
          correct: 1,
        },
      ]),
    },
    {
      day_number: 4,
      title: "Emotional Intelligence & Self-Care",
      description: "Managing your own emotions while supporting others.",
      duration: "45 minutes",
      objectives: [
        "Understand compassion fatigue",
        "Practice self-care strategies",
        "Set healthy boundaries",
      ],
      content:
        "Supporting others can be emotionally demanding. Learning to manage your own emotional responses is essential for sustainable peer support work...",
      has_quiz: false,
      quiz_questions: null,
    },
    {
      day_number: 5,
      title: "Practical Session Simulation",
      description: "Role-playing peer support sessions with feedback.",
      duration: "120 minutes",
      objectives: [
        "Practice full session flow",
        "Receive constructive feedback",
        "Build confidence",
      ],
      content:
        "In this final training module, you will participate in simulated peer support sessions. These practice sessions help you apply everything you have learned...",
      has_quiz: true,
      quiz_questions: JSON.stringify([
        {
          q: "How long should a typical peer session last?",
          options: ["5 minutes", "20-45 minutes", "2 hours", "No limit"],
          correct: 1,
        },
      ]),
    },
  ];

  for (const module of trainingModules) {
    await prisma.trainingModule.upsert({
      where: { day_number: module.day_number },
      update: {},
      create: module,
    });
  }
  console.log(`✅ ${trainingModules.length} training modules ready`);

  // ================================================================
  // 8. INTERN REFERRAL CODES
  // ================================================================
  const referralCodes = [
    "PEER2024A",
    "PEER2024B",
    "PEER2024C",
    "PEER2024D",
    "PEER2024E",
  ];
  for (const code of referralCodes) {
    await prisma.internReferralCode.upsert({
      where: { code },
      update: {},
      create: {
        code,
        institution_id: institution.id,
        is_used: false,
        expires_at: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
      },
    });
  }
  console.log(`✅ ${referralCodes.length} intern referral codes ready`);

  // ================================================================
  // SUMMARY
  // ================================================================
  console.log("\n🎉 Production seed complete!");
  console.log("\n📋 LOGIN CREDENTIALS:");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("Admin:     eternia_admin    / Admin@2024!");
  console.log("SPOC:      spoc_demo        / Spoc@2024!");
  console.log("Expert 1:  dr_priya_sharma  / Expert@2024!");
  console.log("Expert 2:  dr_arjun_mehta   / Expert@2024!");
  console.log("Expert 3:  dr_sneha_kulkarni/ Expert@2024!");
  console.log("Intern 1:  intern_riya       / Intern@2024!");
  console.log("Intern 2:  intern_karan      / Intern@2024!");
  console.log("Therapist: therapist_meena   / Therapist@2024!");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log("\n🏫 Institution Code: DEMO2024");
  console.log("🎯 Intern Referral Codes: PEER2024A thru PEER2024E\n");
}

main()
  .catch((e) => {
    console.error("❌ Seed failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
