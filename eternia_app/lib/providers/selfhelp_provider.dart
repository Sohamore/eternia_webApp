import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../services/selfhelp_service.dart';

class SelfHelpProvider extends ChangeNotifier {
  final SelfHelpService _service;

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>>? _gratitudeEntries;
  List<Map<String, dynamic>>? _journalEntries;
  List<Map<String, dynamic>>? _moodHistory;
  DateTime? _gratitudeLastFetched;
  DateTime? _journalLastFetched;
  DateTime? _moodLastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>>? get gratitudeEntries => _gratitudeEntries;
  List<Map<String, dynamic>>? get journalEntries => _journalEntries;
  List<Map<String, dynamic>>? get moodHistory => _moodHistory;

  SelfHelpProvider(this._service);

  Future<void> fetchGratitude({bool force = false}) async {
    if (!force && _gratitudeLastFetched != null && DateTime.now().difference(_gratitudeLastFetched!) < const Duration(minutes: 5)) return;
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getGratitudeEntries();
      _gratitudeEntries = List<Map<String, dynamic>>.from(data['entries'] as List? ?? []);
      _gratitudeLastFetched = DateTime.now();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createGratitude({required String entry1, String? entry2, String? entry3}) async {
    _error = null;
    try {
      await _service.createGratitude(entry1: entry1, entry2: entry2, entry3: entry3);
      await fetchGratitude(force: true);
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchJournal({bool force = false}) async {
    if (!force && _journalLastFetched != null && DateTime.now().difference(_journalLastFetched!) < const Duration(minutes: 5)) return;
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getJournalEntries();
      _journalEntries = List<Map<String, dynamic>>.from(data['entries'] as List? ?? []);
      _journalLastFetched = DateTime.now();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createJournal({required String content, String? title, String? moodTag}) async {
    _error = null;
    try {
      await _service.createJournal(content: content, title: title, moodTag: moodTag);
      await fetchJournal(force: true);
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteJournal(String id) async {
    _error = null;
    try {
      await _service.deleteJournal(id);
      _journalEntries?.removeWhere((e) => e['id'] == id);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMood({bool force = false}) async {
    if (!force && _moodLastFetched != null && DateTime.now().difference(_moodLastFetched!) < const Duration(minutes: 5)) return;
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getMoodHistory();
      _moodHistory = List<Map<String, dynamic>>.from(data['entries'] as List? ?? []);
      _moodLastFetched = DateTime.now();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> logMood({required int mood, String? note}) async {
    _error = null;
    try {
      await _service.logMood(mood: mood, note: note);
      await fetchMood(force: true);
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }
}
