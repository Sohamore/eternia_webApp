import api from './api';

export async function getVideoSDKToken() {
  const { data } = await api.post('/videosdk/token');
  return data.token;
}

export async function createVideoSDKRoom() {
  const { data } = await api.post('/videosdk/room');
  return { token: data.token, roomId: data.roomId };
}
