import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../services/blackbox_service.dart';

class BlackBoxProvider extends ChangeNotifier {
  final BlackBoxService _service;

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>>? _entries;
  List<Map<String, dynamic>>? _activeSessions;
  bool _hasMore = false;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>>? get entries => _entries;
  List<Map<String, dynamic>>? get activeSessions => _activeSessions;
  bool get hasMore => _hasMore;

  BlackBoxProvider(this._service);

  Future<void> fetchEntries({bool force = false}) async {
    if (!force && _lastFetched != null && DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) return;
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getEntries();
      _entries = List<Map<String, dynamic>>.from(data['entries'] as List? ?? []);
      _hasMore = data['hasMore'] == true;
      _lastFetched = DateTime.now();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createEntry({required String content, String contentType = 'text', bool isPrivate = false}) async {
    _error = null;
    try {
      await _service.createEntry(content: content, contentType: contentType, isPrivate: isPrivate);
      await fetchEntries(force: true);
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEntry(String id) async {
    _error = null;
    try {
      await _service.deleteEntry(id);
      _entries?.removeWhere((e) => e['id'] == id);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchActiveSessions() async {
    _error = null;
    try {
      final data = await _service.getActiveSessions();
      _activeSessions = List<Map<String, dynamic>>.from(data['sessions'] as List? ?? []);
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createSession() async {
    _error = null;
    try {
      final data = await _service.createSession();
      await fetchActiveSessions();
      return data;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelSession(String id) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _service.cancelSession(id);
      await fetchActiveSessions();
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> endSession(String id) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _service.endSession(id);
      await fetchActiveSessions();
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> getSessionById(String id) async {
    _error = null;
    try {
      final data = await _service.getSessionById(id);
      return data['session'] as Map<String, dynamic>?;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchTherapistQueue() async {
    _error = null;
    try {
      final data = await _service.getTherapistQueue();
      return List<Map<String, dynamic>>.from(data['queue'] as List? ?? []);
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> acceptSession(String id, String roomId) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.acceptSession(id, roomId);
      _isLoading = false;
      notifyListeners();
      return data['session'] as Map<String, dynamic>?;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> therapistJoinSession(String id) async {
    _error = null;
    try {
      await _service.therapistJoinSession(id);
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }
}
