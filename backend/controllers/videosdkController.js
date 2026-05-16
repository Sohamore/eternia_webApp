const videosdkService = require('../services/videosdkService');

async function getToken(req, res, next) {
  try {
    const token = videosdkService.generateVideoSDKToken();
    res.json({ token });
  } catch (err) { next(err); }
}

async function createRoom(req, res, next) {
  try {
    const result = await videosdkService.createRoom();
    res.json(result);
  } catch (err) { next(err); }
}

module.exports = { getToken, createRoom };
