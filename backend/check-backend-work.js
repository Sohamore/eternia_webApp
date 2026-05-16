const axios = require('axios');

async function checkBackend() {
  const baseURL = 'http://localhost:3001/api';
  
  console.log("Checking backend health...");
  try {
    const health = await axios.get('http://localhost:3001/health');
    console.log("Health Check:", health.data);
  } catch (err) {
    console.error("Health Check Failed:", err.message);
  }

  console.log("\nChecking Login with Admin credentials...");
  try {
    const login = await axios.post(`${baseURL}/auth/login`, {
      username: 'admin',
      password: 'admin123'
    });
    console.log("Admin Login Success! Token received.");
    
    const token = login.data.token;
    console.log("\nChecking /auth/me with Admin token...");
    const me = await axios.get(`${baseURL}/auth/me`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log("Auth Me Success! User Role:", me.data.user.role);
    
  } catch (err) {
    console.error("Login/Auth Me Failed:", err.response?.data || err.message);
  }
}

checkBackend();
