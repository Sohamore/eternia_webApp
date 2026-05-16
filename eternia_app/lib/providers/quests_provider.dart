import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../services/quests_service.dart';

class QuestsProvider extends ChangeNotifier {
  final QuestsService _service;

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>>? _quests;
  List<Map<String, dynamic>>? _completionsToday;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>>? get quests => _quests;
  List<Map<String, dynamic>>? get completionsToday => _completionsToday;

  QuestsProvider(this._service);

  Future<void> fetchQuests({bool force = false}) async {
    if (!force && _lastFetched != null && DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) return;
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getQuests();
      _quests = List<Map<String, dynamic>>.from(data['quests'] as List? ?? []);
      _lastFetched = DateTime.now();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCompletionsToday() async {
    _error = null;
    try {
      final data = await _service.getCompletionsToday();
      _completionsToday = List<Map<String, dynamic>>.from(data['completions'] as List? ?? []);
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
    }
  }

  Future<bool> completeQuest(String questId) async {
    _error = null;
    try {
      await _service.completeQuest(questId);
      await fetchCompletionsToday();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }
}
