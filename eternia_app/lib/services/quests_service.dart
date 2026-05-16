import '../core/api_client.dart';

class QuestsService {
  final ApiClient _api;

  QuestsService(this._api);

  Future<Map<String, dynamic>> getQuests() async {
    final response = await _api.get('/quests/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> completeQuest(String questId) async {
    final response = await _api.post('/quests/complete', data: {'quest_id': questId});
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getCompletionsToday() async {
    final response = await _api.get('/quests/completions/today');
    return Map<String, dynamic>.from(response.data as Map);
  }
}
