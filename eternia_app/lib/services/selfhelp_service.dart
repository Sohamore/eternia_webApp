import '../core/api_client.dart';

class SelfHelpService {
  final ApiClient _api;

  SelfHelpService(this._api);

  Future<Map<String, dynamic>> createGratitude({
    required String entry1,
    String? entry2,
    String? entry3,
  }) async {
    final response = await _api.post('/selfhelp/gratitude', data: {
      'entry_1': entry1,
      if (entry2 != null) 'entry_2': entry2,
      if (entry3 != null) 'entry_3': entry3,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getGratitudeEntries() async {
    final response = await _api.get('/selfhelp/gratitude');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> createJournal({
    required String content,
    String? title,
    String? moodTag,
  }) async {
    final response = await _api.post('/selfhelp/journal', data: {
      'content': content,
      if (title != null) 'title': title,
      if (moodTag != null) 'mood_tag': moodTag,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getJournalEntries() async {
    final response = await _api.get('/selfhelp/journal');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> deleteJournal(String id) async {
    final response = await _api.delete('/selfhelp/journal/$id');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> logMood({required int mood, String? note}) async {
    final response = await _api.post('/selfhelp/mood', data: {
      'mood': mood,
      if (note != null) 'note': note,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getMoodHistory() async {
    final response = await _api.get('/selfhelp/mood');
    return Map<String, dynamic>.from(response.data as Map);
  }
}
