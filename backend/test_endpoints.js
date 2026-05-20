require('dotenv').config();
const axios = require('axios');
const { signToken } = require('./utils/jwt');

async function main() {
  const studentId = '92a7520a-8458-4741-bf55-0748bdb1f70c'; // soham@eternia.local
  const expertId = 'e10b5feb-1354-4a2e-8091-ce6cfffc78c5';   // dr_soham

  console.log("Generating access token for student...");
  const token = signToken({ userId: studentId });
  console.log("Token generated:", token.substring(0, 20) + "...");

  const client = axios.create({
    baseURL: 'http://localhost:5000/api',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });

  let roomId = null;
  console.log("\n1. Testing room creation via POST /videosdk/room...");
  try {
    const res = await client.post('/videosdk/room');
    console.log("SUCCESS! Room Created:", res.data);
    roomId = res.data.roomId;
  } catch (err) {
    console.error("FAILED to create room:", err.response ? {
      status: err.response.status,
      data: err.response.data
    } : err.message);
    return;
  }

  if (roomId) {
    console.log("\n2. Testing appointment booking via POST /appointments...");
    try {
      const res = await client.post('/appointments', {
        expert_id: expertId,
        slot_time: new Date().toISOString(),
        session_type: 'video',
        credits_charged: 0,
        room_id: roomId
      });
      console.log("SUCCESS! Appointment Booked:", res.data);
    } catch (err) {
      console.error("FAILED to book appointment:", err.response ? {
        status: err.response.status,
        data: err.response.data
      } : err.message);
    }
  }
}

main();
