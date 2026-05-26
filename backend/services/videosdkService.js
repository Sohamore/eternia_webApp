const jwt = require("jsonwebtoken");
const axios = require("axios");
const logger = require("../utils/logger");

function generateVideoSDKToken() {
  const API_KEY = process.env.VIDEOSDK_API_KEY;
  const API_SECRET = process.env.VIDEOSDK_API_SECRET;

  // If credentials are empty or placeholders, generate a mock JWT token using a fallback secret
  if (!API_KEY || !API_SECRET || API_KEY === "your_videosdk_api_key" || API_SECRET === "your_videosdk_api_secret") {
    const payload = {
      apikey: "mock_key",
      permissions: ["allow_join", "allow_mod"],
      version: 2,
    };
    return jwt.sign(payload, "mock_secret", { expiresIn: "2h", algorithm: "HS256" });
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
  
  // If we are using placeholder credentials, immediately bypass the API call and return a mock room ID
  const API_KEY = process.env.VIDEOSDK_API_KEY;
  if (!API_KEY || API_KEY === "your_videosdk_api_key") {
    const mockRoomId = `mock-room-${Math.random().toString(36).substring(2, 10)}`;
    logger.info(`VideoSDK is in fallback/mock mode. Created mock room: ${mockRoomId}`);
    return { token, roomId: mockRoomId };
  }

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

    // Fallback in development mode to prevent local test flows from breaking
    if (process.env.NODE_ENV === "development") {
      const mockRoomId = `mock-room-fallback-${Math.random().toString(36).substring(2, 10)}`;
      logger.warn(`Creating fallback mock room for development: ${mockRoomId}`);
      return { token, roomId: mockRoomId };
    }

    throw Object.assign(new Error("Failed to create VideoSDK room"), {
      status: 502,
    });
  }
}

module.exports = { generateVideoSDKToken, createRoom };
