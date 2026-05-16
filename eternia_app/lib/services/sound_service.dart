import '../core/api_client.dart';

class SoundService {
  final ApiClient _api;

  SoundService(this._api);

  Future<List<Map<String, dynamic>>> getTracks() async {
    final response = await _api.get('/sound');
    final data = response.data;
    if (data is Map && data.containsKey('sounds')) {
      return List<Map<String, dynamic>>.from(data['sounds'] as List);
    }
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  List<Map<String, dynamic>> filterByCategory(
    List<Map<String, dynamic>> tracks,
    String category,
  ) {
    return tracks.where((t) => t['category'] == category).toList();
  }
}
