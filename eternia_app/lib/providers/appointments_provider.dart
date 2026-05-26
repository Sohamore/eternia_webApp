import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../services/appointments_service.dart';

class AppointmentsProvider extends ChangeNotifier {
  final AppointmentsService _service;

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>>? _experts;
  List<Map<String, dynamic>>? _slots;
  List<Map<String, dynamic>>? _appointments;
  List<Map<String, dynamic>>? _messages;
  DateTime? _lastFetched;

  Map<String, dynamic>? _lastBookedAppointment;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>>? get experts => _experts;
  List<Map<String, dynamic>>? get slots => _slots;
  List<Map<String, dynamic>>? get appointments => _appointments;
  List<Map<String, dynamic>>? get messages => _messages;
  Map<String, dynamic>? get lastBookedAppointment => _lastBookedAppointment;

  AppointmentsProvider(this._service);

  Future<void> fetchExperts({String? institutionId, bool force = false}) async {
    if (!force &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5))
      return;
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getExperts(institutionId: institutionId);
      _experts = List<Map<String, dynamic>>.from(
        data['experts'] as List? ?? [],
      );
      _lastFetched = DateTime.now();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSlots(String expertId) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getSlots(expertId);
      _slots = List<Map<String, dynamic>>.from(data['slots'] as List? ?? []);
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getHistory();
      _appointments = List<Map<String, dynamic>>.from(
        data['appointments'] as List? ?? [],
      );
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> book({
    required String expertId,
    String? slotId,
    required String slotTime,
    String? sessionType,
    int? creditsCharged,
    String? roomId,
  }) async {
    _error = null;
    _lastBookedAppointment = null;
    try {
      final data = await _service.book(
        expertId: expertId,
        slotId: slotId,
        slotTime: slotTime,
        sessionType: sessionType,
        creditsCharged: creditsCharged,
        roomId: roomId,
      );
      if (data['appointment'] != null) {
        _lastBookedAppointment = Map<String, dynamic>.from(
          data['appointment'] as Map,
        );
      }
      await fetchHistory();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancel(String id) async {
    _error = null;
    try {
      await _service.cancel(id);
      await fetchHistory();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeSession(String id, [String? notes]) async {
    _error = null;
    try {
      await _service.complete(id, notes);
      await fetchHistory();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMessages(String appointmentId) async {
    _error = null;
    try {
      final data = await _service.getMessages(appointmentId);
      _messages = List<Map<String, dynamic>>.from(
        data['messages'] as List? ?? [],
      );
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String appointmentId, String content) async {
    _error = null;
    try {
      await _service.sendMessage(appointmentId, content);
      await fetchMessages(appointmentId);
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }
}
