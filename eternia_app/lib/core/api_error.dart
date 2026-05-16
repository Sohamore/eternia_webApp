/// Structured error types for programmatic error handling in the UI.
enum ApiErrorType {
  /// No internet / connection refused
  network,

  /// Connect or receive timeout exceeded
  timeout,

  /// 5xx responses
  server,

  /// 4xx responses (error message from backend)
  validation,

  /// 401 non-TOKEN_EXPIRED (session invalid)
  unauthorized,

  /// Unexpected errors
  unknown,
}

/// Structured error class returned by [ApiClient] for all failed requests.
class ApiError {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final String? backendCode;

  ApiError({
    required this.type,
    required this.message,
    this.statusCode,
    this.backendCode,
  });
}
