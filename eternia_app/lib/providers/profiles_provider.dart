import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_error.dart';
import '../services/profiles_service.dart';

class ProfilesProvider extends ChangeNotifier {
  final ProfilesService _service;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _profile;
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get profile => _profile;

  ProfilesProvider(this._service);

  Future<void> fetchProfile({bool force = false}) async {
    if (!force && _lastFetched != null && DateTime.now().difference(_lastFetched!) < const Duration(minutes: 5)) return;
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getProfile();
      _profile = data['profile'] as Map<String, dynamic>?;
      _lastFetched = DateTime.now();
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    _error = null;
    try {
      final data = await _service.updateProfile(fields);
      _profile = data['profile'] as Map<String, dynamic>?;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmergencyContact({String? name, String? phone, String? relation, bool contactIsSelf = false}) async {
    _error = null;
    try {
      await _service.updateEmergencyContact(emergencyName: name, emergencyPhone: phone, emergencyRelation: relation, contactIsSelf: contactIsSelf);
      return true;
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return false;
    } on ApiError catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> validateSpocQr(String qrPayload) async {
    _error = null;
    try {
      return await _service.validateSpocQr(qrPayload);
    } on DioException catch (e) {
      _error = ApiClient.classifyError(e).message;
      notifyListeners();
      return null;
    }
  }
}
