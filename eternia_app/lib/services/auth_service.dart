import '../core/api_client.dart';

/// Stateless service handling all authentication-related API calls.
///
/// Each method returns the full response data as a [Map<String, dynamic>].
/// DioExceptions are left to propagate — the provider layer handles them.
class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  /// POST /auth/login
  /// Returns: {token, refreshToken, user, creditBalance}
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _api.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /auth/register
  /// Returns: {token, refreshToken, user}
  Future<Map<String, dynamic>> register(
    String username,
    String password, {
    Map<String, dynamic>? metadata,
  }) async {
    final body = <String, dynamic>{
      'username': username,
      'password': password,
      if (metadata != null) ...metadata,
    };
    final response = await _api.post('/auth/register', data: body);
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /auth/send-otp
  /// Returns: {success, message}
  Future<Map<String, dynamic>> sendOtp(String email) async {
    final response = await _api.post('/auth/send-otp', data: {'email': email});
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /auth/verify-otp
  /// Returns: {success, message}
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await _api.post(
      '/auth/verify-otp',
      data: {'email': email, 'otp': otp},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /auth/reset-password-otp
  /// Returns: {success, message}
  Future<Map<String, dynamic>> resetPasswordOtp(
    String username,
    String newPassword,
    String otp,
  ) async {
    final response = await _api.post(
      '/auth/reset-password-otp',
      data: {'username': username, 'newPassword': newPassword, 'otp': otp},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /auth/activate-account
  /// Returns: {token, refreshToken, user}
  Future<Map<String, dynamic>> activateAccount(
    String tempCredentialId,
    String username,
    String password, {
    Map<String, dynamic>? emergencyContact,
    Map<String, dynamic>? studentIdData,
  }) async {
    final body = <String, dynamic>{
      'tempCredentialId': tempCredentialId,
      'username': username,
      'password': password,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (studentIdData != null) 'studentIdData': studentIdData,
    };
    final response = await _api.post('/auth/activate-account', data: body);
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /auth/logout
  /// Returns: {success}
  Future<Map<String, dynamic>> logout() async {
    final response = await _api.post('/auth/logout');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /auth/me
  /// Returns: {user, creditBalance}
  Future<Map<String, dynamic>> fetchMe() async {
    final response = await _api.get('/auth/me');
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /auth/refresh
  /// Returns: {token, refreshToken}
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await _api.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /auth/verify-institutional-code
  /// Returns: {success, institutionName, institutionId, tempCredentialId}
  Future<Map<String, dynamic>> verifyInstitutionalCode(String code) async {
    final response = await _api.post(
      '/auth/verify-institutional-code',
      data: {'code': code},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
