import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../services/peers_service.dart';

class PeersProvider extends ChangeNotifier {
  final PeersService _service;

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>>? _interns;
  List<Map<String, dynamic>>? _sessions;
  List<Map<String, dynamic>>? _messages;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>>? get interns => _interns;
  List<Map<String, dynamic>>? get sessions => _sessions;
  List<Map<String, dynamic>>? get messages => _messages;

  PeersProvider(this._service);

  Future<void> fetchInterns({bool force = false}) async {
    if (!force && _lastFetched != null && DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) return;
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getInterns();
      _interns = List<Map<String, dynamic>>.from(data['interns'] as List? ?? []);
      _lastFetched = DateTime.now();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSessions() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getSessions();
      _sessions = List<Map<String, dynamic>>.from(data['sessions'] as List? ?? []);
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createSession(String internId) async {
    _error = null;
    try {
      await _service.createSession(internId);
      await fetchSessions();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMessages(String sessionId) async {
    _error = null;
    try {
      final data = await _service.getMessages(sessionId);
      _messages = List<Map<String, dynamic>>.from(data['messages'] as List? ?? []);
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String sessionId, String content) async {
    _error = null;
    try {
      await _service.sendMessage(sessionId, content);
      await fetchMessages(sessionId);
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> endSession(String id) async {
    _error = null;
    try {
      await _service.endSession(id);
      await fetchSessions();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> startCall(String sessionId) async {
    _error = null;
    try {
      final data = await _service.startCall(sessionId);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }
}
