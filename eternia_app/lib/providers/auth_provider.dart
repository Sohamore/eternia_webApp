import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../core/api_error.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  bool _isInitializing = true;
  bool _isLoading = false;
  String? _error;
  String? _token;
  Map<String, dynamic>? _userProfile;
  int _creditBalance = 0;

  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get userProfile => _userProfile;
  int get creditBalance => _creditBalance;

  AuthProvider({
    required AuthService authService,
    required TokenStorage tokenStorage,
  }) : _authService = authService,
       _tokenStorage = tokenStorage {
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final storedToken = await _tokenStorage.getAccessToken();
      if (storedToken == null) {
        debugPrint('[AuthProvider] No stored token, unauthenticated');
        return;
      }

      _token = storedToken;
      debugPrint('[AuthProvider] Found stored token, restoring session...');
      try {
        final data = await _authService.fetchMe();
        _userProfile = data['user'] as Map<String, dynamic>?;
        _creditBalance = (data['creditBalance'] as num?)?.toInt() ?? 0;
        debugPrint(
          '[AuthProvider] Session restored: ${_userProfile?['username']}',
        );
      } on DioException catch (e) {
        debugPrint(
          '[AuthProvider] Session restore failed: ${e.response?.statusCode} ${e.response?.data}',
        );
        _token = null;
        _userProfile = null;
        _creditBalance = 0;
        await _tokenStorage.clearTokens();
      }
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('[AuthProvider] login attempt: $username');
      final data = await _authService.login(username, password);
      debugPrint('[AuthProvider] login success: ${data['user']?['username']}');
      _token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String;
      _userProfile = data['user'] as Map<String, dynamic>?;
      _creditBalance = (data['creditBalance'] as num?)?.toInt() ?? 0;

      await _tokenStorage.saveTokens(
        accessToken: _token!,
        refreshToken: refreshToken,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      debugPrint(
        '[AuthProvider] login error: ${e.response?.statusCode} ${e.response?.data}',
      );
      final apiError = ApiClient.classifyError(e);
      _error = apiError.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String username,
    String password, {
    Map<String, dynamic>? metadata,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('[AuthProvider] register attempt: $username');
      final data = await _authService.register(
        username,
        password,
        metadata: metadata,
      );
      debugPrint(
        '[AuthProvider] register success: ${data['user']?['username']}',
      );
      _token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String;
      _userProfile = data['user'] as Map<String, dynamic>?;

      await _tokenStorage.saveTokens(
        accessToken: _token!,
        refreshToken: refreshToken,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      debugPrint(
        '[AuthProvider] register error: ${e.response?.statusCode} ${e.response?.data}',
      );
      final apiError = ApiClient.classifyError(e);
      _error = apiError.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMe() async {
    try {
      final data = await _authService.fetchMe();
      _userProfile = data['user'] as Map<String, dynamic>?;
      _creditBalance = (data['creditBalance'] as num?)?.toInt() ?? 0;
      notifyListeners();
    } on DioException {
      await logout();
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    _token = null;
    _userProfile = null;
    _creditBalance = 0;
    _error = null;
    await _tokenStorage.clearTokens();
    notifyListeners();
  }

  Future<bool> sendOTP(String emailOrUsername) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.sendOtp(emailOrUsername);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      final apiError = ApiClient.classifyError(e);
      _error = apiError.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOTP(String emailOrUsername, String otp) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.verifyOtp(emailOrUsername, otp);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      final apiError = ApiClient.classifyError(e);
      _error = apiError.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPasswordOTP(
    String username,
    String newPassword,
    String otp,
  ) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.resetPasswordOtp(username, newPassword, otp);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      final apiError = ApiClient.classifyError(e);
      _error = apiError.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void handleSessionExpired() {
    _token = null;
    _userProfile = null;
    _creditBalance = 0;
    _error = null;
    notifyListeners();
  }
}
