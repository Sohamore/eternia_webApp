require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function createAdmin(username, password) {
  const email = username.includes('@') ? username.toLowerCase() : `${username.toLowerCase()}@eternia.local`;

  try {
    // Check if user exists
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      console.log(`User with email ${email} already exists. Updating password and role to admin...`);
      
      const password_hash = await bcrypt.hash(password, 12);

      await prisma.user.update({
        where: { id: existing.id },
        data: { password_hash }
      });

      // Update role to admin if user exists
      await prisma.profile.update({
        where: { id: existing.id },
        data: { role: 'admin' }
      });
      
      await prisma.userRole.upsert({
        where: { user_id_role: { user_id: existing.id, role: 'admin' } },
        update: {},
        create: { user_id: existing.id, role: 'admin' }
      });
      
      console.log(`User ${username} has been promoted to Admin.`);
      return;
    }

    const password_hash = await bcrypt.hash(password, 12);

    await prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          email,
          password_hash,
        }
      });

      await tx.profile.create({
        data: {
          id: user.id,
          username: username.toLowerCase(),
          role: 'admin',
          is_active: true,
          is_verified: true,
        }
      });

      await tx.userRole.create({
        data: {
          user_id: user.id,
          role: 'admin'
        }
      });

      await tx.userPrivate.create({
        data: {
          user_id: user.id
        }
      });

      console.log(`Admin account created successfully!`);
      console.log(`Email: ${email}`);
      console.log(`Password: ${password}`);
    }, {
      timeout: 15000 // 15 seconds
    });

  } catch (error) {
    console.error('Error creating admin:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Get arguments from command line
const args = process.argv.slice(2);
const username = args[0] || 'admin';
const password = args[1] || 'admin123';

createAdmin(username, password);
