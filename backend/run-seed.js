/**
 * Run this ONCE after backend is deployed to Render.
 * node run-seed.js
 */
const axios = require('axios');
const BASE = 'https://eternia-ef-prisma.onrender.com/api';

async function runSeed() {
  console.log('Logging in as admin...');
  const { data: login } = await axios.post(BASE + '/auth/login', {
    username: 'admin',
    password: 'admin123',
  });

  const H = { Authorization: 'Bearer ' + login.token };
  console.log('Admin login OK. Running seed...\n');

  const { data } = await axios.post(BASE + '/admin/seed', {}, { headers: H });

  console.log('✅ SEED COMPLETE!\n');
  console.log('Institution Code:', data.institutionCode);
  console.log('\n📋 CREDENTIALS:');
  Object.entries(data.credentials).forEach(([k, v]) => console.log(' ', k + ':', v));
  console.log('\nResults:');
  console.log(JSON.stringify(data.results, null, 2));
}

runSeed().catch((e) => {
  const err = e.response?.data?.error || e.message;
  if (err.includes('not found')) {
    console.log('❌ Backend not updated yet. Please trigger manual deploy on Render first.');
  } else if (err.includes('auth attempts')) {
    console.log('❌ Rate limited. Wait 2 minutes and try again.');
  } else {
    console.log('❌ Error:', err);
  }
});
