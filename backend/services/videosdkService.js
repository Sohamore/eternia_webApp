const jwt = require("jsonwebtoken");
const axios = require("axios");
const logger = require("../utils/logger");

function generateVideoSDKToken() {
  const API_KEY = process.env.VIDEOSDK_API_KEY;
  const API_SECRET = process.env.VIDEOSDK_API_SECRET;

  if (!API_KEY || !API_SECRET) {
    throw new Error("VideoSDK credentials not configured");
  }

  const payload = {
    apikey: API_KEY,
    permissions: ["allow_join", "allow_mod"],
    version: 2,
  };

  return jwt.sign(payload, API_SECRET, { expiresIn: "2h", algorithm: "HS256" });
}

async function createRoom() {
  const token = generateVideoSDKToken();
  try {
    const response = await axios.post(
      "https://api.videosdk.live/v2/rooms",
      {},
      {
        headers: {
          Authorization: token,
          "Content-Type": "application/json",
        },
        timeout: 10000,
      },
    );
    return { token, roomId: response.data.roomId };
  } catch (err) {
    logger.error("VideoSDK room creation failed:", err.message);
    throw Object.assign(new Error("Failed to create VideoSDK room"), {
      status: 502,
    });
  }
}

module.exports = { generateVideoSDKToken, createRoom };
