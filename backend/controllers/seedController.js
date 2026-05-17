const prisma = require('../prisma/client');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

async function runProductionSeed(req, res, next) {
  try {
    // Only allow admin role
    if (req.user?.role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const results = {};

    // ── 1. INSTITUTION ──────────────────────────────────────────
    let institution = await prisma.institution.findFirst({
      where: { eternia_code_hash: 'DEMO2024' }
    });
    if (!institution) {
      institution = await prisma.institution.create({
        data: {
          name: 'Demo University',
          eternia_code_hash: 'DEMO2024',
          plan_type: 'premium',
          credits_pool: 10000,
          is_active: true,
        }
      });
      results.institution = 'created';
    } else {
      results.institution = 'already exists';
    }

    // ── 2. ECC STABILITY POOL ────────────────────────────────────
    await prisma.eccStabilityPool.upsert({
      where: { institution_id: institution.id },
      update: {},
      create: { institution_id: institution.id, balance: 5000, total_contributed: 5000, total_disbursed: 0 }
    });

    // ── 3. USERS ─────────────────────────────────────────────────
    const usersToCreate = [
      { username: 'spoc_demo',          password: 'Spoc@2024!',      role: 'spoc',      specialty: null,                             institution_id: institution.id },
      { username: 'dr_priya_sharma',    password: 'Expert@2024!',    role: 'expert',    specialty: 'Anxiety & Stress Management',    institution_id: institution.id },
      { username: 'dr_arjun_mehta',     password: 'Expert@2024!',    role: 'expert',    specialty: 'Academic Pressure & Focus',      institution_id: institution.id },
      { username: 'dr_sneha_kulkarni',  password: 'Expert@2024!',    role: 'expert',    specialty: 'Relationship & Social Anxiety',  institution_id: institution.id },
      { username: 'intern_riya',        password: 'Intern@2024!',    role: 'intern',    specialty: 'Peer Support Counselor',         institution_id: institution.id },
      { username: 'intern_karan',       password: 'Intern@2024!',    role: 'intern',    specialty: 'Peer Support Counselor',         institution_id: institution.id },
      { username: 'therapist_meena',    password: 'Therapist@2024!', role: 'therapist', specialty: 'BlackBox Anonymous Therapy',     institution_id: institution.id },
    ];

    const createdUserIds = {};
    results.users = {};

    for (const u of usersToCreate) {
      const existingProfile = await prisma.profile.findFirst({ where: { username: u.username } });
      if (existingProfile) {
        results.users[u.username] = 'already exists';
        createdUserIds[u.username] = existingProfile.id;
        continue;
      }
      const password_hash = await bcrypt.hash(u.password, 12);
      const uniqueTag = crypto.randomUUID().replace(/-/g, '').slice(0, 10);
      const email = `${u.username}_${uniqueTag}@eternia.local`;
      const created = await prisma.$transaction(async (tx) => {
        const user = await tx.user.create({ data: { email, password_hash } });
        await tx.profile.create({ data: { id: user.id, username: u.username, role: u.role, institution_id: u.institution_id, specialty: u.specialty, is_active: true, is_verified: true, training_status: u.role === 'intern' ? 'active' : null } });
        await tx.userRole.create({ data: { user_id: user.id, role: u.role } });
        await tx.creditTransaction.create({ data: { user_id: user.id, delta: 100, type: 'grant', notes: 'Welcome bonus' } });
        await tx.userPrivate.create({ data: { user_id: user.id } });
        return user;
      });
      createdUserIds[u.username] = created.id;
      results.users[u.username] = 'created';
    }

    // ── 4. EXPERT AVAILABILITY ────────────────────────────────────
    const experts = ['dr_priya_sharma', 'dr_arjun_mehta', 'dr_sneha_kulkarni'];
    results.expertSlots = {};
    for (const expertUsername of experts) {
      const expertId = createdUserIds[expertUsername];
      if (!expertId) continue;
      const existing = await prisma.expertAvailability.count({ where: { expert_id: expertId } });
      if (existing > 0) { results.expertSlots[expertUsername] = `${existing} slots already exist`; continue; }
      const slots = [];
      const now = new Date();
      for (let day = 1; day <= 7; day++) {
        for (const hour of [10, 12, 14, 16]) {
          const start = new Date(now);
          start.setDate(now.getDate() + day);
          start.setHours(hour, 0, 0, 0);
          const end = new Date(start);
          end.setHours(hour + 1, 0, 0, 0);
          slots.push({ expert_id: expertId, institution_id: institution.id, start_time: start, end_time: end, is_booked: false });
        }
      }
      await prisma.expertAvailability.createMany({ data: slots, skipDuplicates: true });
      results.expertSlots[expertUsername] = `${slots.length} slots created`;
    }

    // ── 5. QUEST CARDS ───────────────────────────────────────────
    const quests = [
      { title: 'Morning Mindfulness',   description: 'Spend 5 minutes in silent reflection before your day begins.', xp_reward: 10, category: 'mindfulness' },
      { title: 'Gratitude Journal',      description: 'Write 3 specific things you are genuinely grateful for today.', xp_reward: 10, category: 'gratitude' },
      { title: 'Deep Breathing',         description: 'Practice 4-7-8 breathing for 5 minutes. Inhale 4s, hold 7s, exhale 8s.', xp_reward: 10, category: 'breathing' },
      { title: 'Digital Detox Hour',     description: 'Put your phone away for 1 hour and do something offline.', xp_reward: 15, category: 'wellness' },
      { title: 'Connect with Nature',    description: 'Step outside for 15+ minutes. Observe with full attention.', xp_reward: 10, category: 'wellness' },
      { title: 'Random Act of Kindness', description: 'Do something kind for someone without expecting anything.', xp_reward: 15, category: 'social' },
      { title: 'Body Scan Meditation',   description: 'Slowly bring awareness to each body part from feet to head.', xp_reward: 10, category: 'mindfulness' },
      { title: 'Evening Reflection',     description: 'Write 3 things that went well today and why.', xp_reward: 10, category: 'gratitude' },
      { title: 'Emotion Labeling',       description: 'Pause throughout the day and name 5 distinct emotions you feel.', xp_reward: 15, category: 'self-awareness' },
      { title: 'Study Pomodoro',         description: '25 min focused study + 5 min break, repeat 4 times.', xp_reward: 20, category: 'academic' },
      { title: 'Talk to Someone',        description: 'Have a genuine conversation with a friend or classmate.', xp_reward: 15, category: 'social' },
      { title: 'Hydration Challenge',    description: 'Drink 8 glasses of water today. Notice how your mood changes.', xp_reward: 5, category: 'wellness' },
    ];
    let questsCreated = 0;
    for (const q of quests) {
      const existing = await prisma.questCard.findFirst({ where: { title: q.title } });
      if (!existing) {
        await prisma.questCard.create({ data: { ...q, is_active: true } });
        questsCreated++;
      }
    }
    results.quests = `${questsCreated} created, ${quests.length - questsCreated} already existed`;

    // ── 6. SOUND CONTENT ─────────────────────────────────────────
    const sounds = [
      { title: 'Ocean Waves',          artist: 'Nature Sounds',    category: 'nature',       file_url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', duration_sec: 300,  cover_emoji: '🌊' },
      { title: 'Forest Rain',          artist: 'Nature Sounds',    category: 'nature',       file_url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3', duration_sec: 420,  cover_emoji: '🌧️' },
      { title: 'Tibetan Singing Bowl', artist: 'Healing Sounds',   category: 'meditation',   file_url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3', duration_sec: 600,  cover_emoji: '🎵' },
      { title: 'Morning Birds',        artist: 'Nature Sounds',    category: 'nature',       file_url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3', duration_sec: 360,  cover_emoji: '🐦' },
      { title: 'White Noise Focus',    artist: 'Focus Lab',        category: 'focus',        file_url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3', duration_sec: 1800, cover_emoji: '🎧' },
      { title: 'Calm Piano',           artist: 'Mindful Music',    category: 'instrumental', file_url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3', duration_sec: 240,  cover_emoji: '🎹' },
      { title: 'Deep Sleep Waves',     artist: 'Sleep Lab',        category: 'sleep',        file_url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3', duration_sec: 3600, cover_emoji: '😴' },
      { title: 'Study Lo-Fi',          artist: 'Lo-Fi Collective', category: 'lofi',         file_url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3', duration_sec: 5400, cover_emoji: '📚' },
    ];
    let soundsCreated = 0;
    for (const s of sounds) {
      const existing = await prisma.soundContent.findFirst({ where: { title: s.title } });
      if (!existing) {
        await prisma.soundContent.create({ data: { ...s, is_active: true, play_count: 0 } });
        soundsCreated++;
      }
    }
    results.sounds = `${soundsCreated} created, ${sounds.length - soundsCreated} already existed`;

    // ── 7. TRAINING MODULES ──────────────────────────────────────
    const trainingModules = [
      { day_number: 1, title: 'Introduction to Peer Support',    description: 'Understanding your role as a peer support intern.',               duration: '45 minutes',  objectives: ['Understand peer support principles', 'Learn platform guidelines', 'Review ethics'],                    content: 'Welcome to Eternia Peer Support Training. Your role is to provide empathetic, non-judgmental support to fellow students.', has_quiz: false, quiz_questions: null },
      { day_number: 2, title: 'Active Listening Techniques',     description: 'Mastering deep listening and reflective communication.',           duration: '60 minutes',  objectives: ['Practice active listening', 'Use reflective statements', 'Avoid unsolicited advice'],               content: 'Active listening is the foundation of effective peer support. Be fully present, avoid judgment, and reflect back what you hear.', has_quiz: false, quiz_questions: null },
      { day_number: 3, title: 'Crisis Recognition & Escalation', description: 'Identifying warning signs and knowing when to escalate.',          duration: '90 minutes',  objectives: ['Recognize crisis indicators', 'Know escalation procedures', 'Practice de-escalation'],              content: 'Warning signs include expressions of hopelessness and mentions of self-harm. Always escalate when in doubt.', has_quiz: false, quiz_questions: null },
      { day_number: 4, title: 'Emotional Intelligence & Self-Care', description: 'Managing your emotions while supporting others.',               duration: '45 minutes',  objectives: ['Understand compassion fatigue', 'Practice self-care', 'Set healthy boundaries'],                    content: 'Supporting others is emotionally demanding. Learning to manage your own responses is essential for sustainable support work.', has_quiz: false, quiz_questions: null },
      { day_number: 5, title: 'Practical Session Simulation',    description: 'Role-playing peer support sessions with feedback.',               duration: '120 minutes', objectives: ['Practice full session flow', 'Receive feedback', 'Build confidence'],                              content: 'Practice simulated peer support sessions. Apply everything you have learned in realistic scenarios.', has_quiz: false, quiz_questions: null },
    ];
    let modulesCreated = 0;
    for (const m of trainingModules) {
      const existing = await prisma.trainingModule.findFirst({ where: { day_number: m.day_number } });
      if (!existing) { await prisma.trainingModule.create({ data: m }); modulesCreated++; }
    }
    results.trainingModules = `${modulesCreated} created`;

    // ── 8. INTERN REFERRAL CODES ─────────────────────────────────
    const referralCodes = ['PEER2024A', 'PEER2024B', 'PEER2024C'];
    let codesCreated = 0;
    for (const code of referralCodes) {
      const existing = await prisma.internReferralCode.findFirst({ where: { code } });
      if (!existing) {
        await prisma.internReferralCode.create({ data: { code, institution_id: institution.id, is_used: false, expires_at: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000) } });
        codesCreated++;
      }
    }
    results.referralCodes = `${codesCreated} created`;

    return res.json({
      success: true,
      message: 'Production seed completed successfully',
      institutionCode: 'DEMO2024',
      credentials: {
        spoc: 'spoc_demo / Spoc@2024!',
        experts: 'dr_priya_sharma, dr_arjun_mehta, dr_sneha_kulkarni / Expert@2024!',
        interns: 'intern_riya, intern_karan / Intern@2024!',
        therapist: 'therapist_meena / Therapist@2024!'
      },
      results
    });

  } catch (err) {
    next(err);
  }
}

module.exports = { runProductionSeed };
