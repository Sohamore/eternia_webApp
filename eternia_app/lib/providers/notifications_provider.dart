import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../services/notifications_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationsService _service;

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>>? _notifications;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>>? get notifications => _notifications;
  int get unreadCount => _notifications != null ? _service.getUnreadCount(_notifications!) : 0;

  NotificationsProvider(this._service);

  Future<void> fetchNotifications({bool force = false}) async {
    if (!force && _lastFetched != null && DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) return;
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getNotifications();
      _notifications = List<Map<String, dynamic>>.from(data['notifications'] as List? ?? []);
      _lastFetched = DateTime.now();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAsRead(String id) async {
    _error = null;
    try {
      await _service.markAsRead(id);
      final idx = _notifications?.indexWhere((n) => n['id'] == id);
      if (idx != null && idx >= 0) {
        _notifications![idx]['is_read'] = true;
      }
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    _error = null;
    try {
      await _service.markAllAsRead();
      _notifications?.forEach((n) => n['is_read'] = true);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }
}
