import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import 'package:dio/dio.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _userProfile;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get userProfile => _userProfile;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      await fetchMe();
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        _token = data['token'];
        _userProfile = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint("Login error: ${e.response?.data ?? e.message}");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String username, String password, {Map<String, dynamic>? metadata}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post('/auth/register', data: {
        'username': username,
        'password': password,
        ...?metadata,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        // After registration, we usually login the user
        return await login(username, password);
      }
    } on DioException catch (e) {
      debugPrint("Register error: ${e.response?.data ?? e.message}");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchMe() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      if (response.statusCode == 200) {
        _userProfile = response.data['user'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Fetch me error: $e");
      logout();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _userProfile = null;
    notifyListeners();
  }

  // --- OTP & Password Reset Methods ---

  Future<bool> sendOTP(String emailOrUsername) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post('/auth/send-otp', data: {
        'email': emailOrUsername,
      });
      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOTP(String emailOrUsername, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post('/auth/verify-otp', data: {
        'email': emailOrUsername,
        'otp': otp,
      });
      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPasswordOTP(String username, String newPassword, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post('/auth/reset-password-otp', data: {
        'username': username,
        'newPassword': newPassword,
        'otp': otp,
      });
      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
