import '../core/api_client.dart';

class VideoSDKService {
  final ApiClient _api;

  VideoSDKService(this._api);

  Future<Map<String, dynamic>> getToken() async {
    final response = await _api.post('/videosdk/token');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> createRoom() async {
    final response = await _api.post('/videosdk/room');
    return Map<String, dynamic>.from(response.data as Map);
  }
}
