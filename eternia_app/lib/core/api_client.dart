import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_error.dart';
import 'env_config.dart';
import 'token_storage.dart';

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;
  final List<({RequestOptions options, Completer<Response> completer})>
      _requestQueue = [];
  static const int _maxQueueSize = 50;

  /// Called when the session is irrecoverably expired
  /// (refresh failed or 401 without TOKEN_EXPIRED).
  VoidCallback? onSessionExpired;

  ApiClient({required TokenStorage tokenStorage, Dio? dio})
      : _tokenStorage = tokenStorage,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: EnvConfig.baseUrl,
              connectTimeout: const Duration(seconds: 120),
              receiveTimeout: const Duration(seconds: 120),
              headers: {'Content-Type': 'application/json'},
            )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  /// For backward compatibility during migration.
  Dio get dio => _dio;

  // --- Public HTTP methods ---

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }

  // --- Interceptor handlers ---

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
      DioException error, ErrorInterceptorHandler handler) async {
    final response = error.response;

    // Check for 401 TOKEN_EXPIRED
    if (response?.statusCode == 401) {
      final backendCode =
          response?.data is Map ? response?.data['code'] : null;

      if (backendCode == 'TOKEN_EXPIRED') {
        // Attempt token refresh
        if (!_isRefreshing) {
          _isRefreshing = true;
          try {
            final refreshToken = await _tokenStorage.getRefreshToken();
            if (refreshToken == null) {
              await _handleSessionExpired();
              handler.reject(error);
              return;
            }

            // Call refresh endpoint directly (bypass interceptors)
            final refreshDio = Dio(BaseOptions(baseUrl: EnvConfig.baseUrl));
            final refreshResponse = await refreshDio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            if (refreshResponse.statusCode == 200) {
              final newAccessToken =
                  refreshResponse.data['token'] as String;
              final newRefreshToken =
                  refreshResponse.data['refreshToken'] as String;
              await _tokenStorage.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
              );

              // Retry original request
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final retryResponse = await _dio.fetch(error.requestOptions);
              handler.resolve(retryResponse);

              // Replay queued requests
              _replayQueue(newAccessToken);
            } else {
              await _handleSessionExpired();
              _rejectQueue(error);
              handler.reject(error);
            }
          } catch (e) {
            await _handleSessionExpired();
            _rejectQueue(error);
            handler.reject(error);
          } finally {
            _isRefreshing = false;
          }
        } else {
          // Already refreshing — enqueue this request
          if (_requestQueue.length < _maxQueueSize) {
            final completer = Completer<Response>();
            _requestQueue
                .add((options: error.requestOptions, completer: completer));
            try {
              final response = await completer.future;
              handler.resolve(response);
            } catch (e) {
              handler.reject(error);
            }
          } else {
            handler.reject(error);
          }
        }
        return;
      } else {
        // 401 without TOKEN_EXPIRED — session invalid
        await _handleSessionExpired();
        handler.reject(error);
        return;
      }
    }

    // Non-401 errors — pass through
    handler.reject(error);
  }

  Future<void> _handleSessionExpired() async {
    await _tokenStorage.clearTokens();
    onSessionExpired?.call();
  }

  void _replayQueue(String newToken) {
    final queue = List.of(_requestQueue);
    _requestQueue.clear();
    for (final item in queue) {
      item.options.headers['Authorization'] = 'Bearer $newToken';
      _dio.fetch(item.options).then(
            (response) => item.completer.complete(response),
            onError: (e) => item.completer.completeError(e),
          );
    }
  }

  void _rejectQueue(DioException error) {
    final queue = List.of(_requestQueue);
    _requestQueue.clear();
    for (final item in queue) {
      item.completer.completeError(error);
    }
  }

  /// Converts a [DioException] into a structured [ApiError].
  ///
  /// Services should call this method to translate Dio errors into
  /// user-friendly, typed errors for the UI layer.
  static ApiError classifyError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return ApiError(
          type: ApiErrorType.network,
          message: 'No internet connection. Please check your network.',
          statusCode: 0,
        );
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiError(
          type: ApiErrorType.timeout,
          message: 'Request timed out. Please try again.',
          statusCode: 0,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final data = error.response?.data;
        final backendMessage = data is Map ? data['error'] as String? : null;
        final backendCode = data is Map ? data['code'] as String? : null;

        if (statusCode == 401) {
          return ApiError(
            type: ApiErrorType.unauthorized,
            message: backendMessage != null && backendMessage != 'Internal server error'
                ? backendMessage
                : 'Invalid credentials. Check your username and password.',
            statusCode: statusCode,
            backendCode: backendCode,
          );
        }
        if (statusCode == 409) {
          return ApiError(
            type: ApiErrorType.validation,
            message: 'Username already taken. Try a different one.',
            statusCode: statusCode,
            backendCode: backendCode,
          );
        }
        if (statusCode >= 500) {
          return ApiError(
            type: ApiErrorType.server,
            message: 'Server error. Please try again later.',
            statusCode: statusCode,
          );
        }
        // 4xx
        return ApiError(
          type: ApiErrorType.validation,
          message: backendMessage ?? 'Request failed',
          statusCode: statusCode,
          backendCode: backendCode,
        );
      default:
        return ApiError(
          type: ApiErrorType.unknown,
          message: 'An unexpected error occurred.',
          statusCode: 0,
        );
    }
  }
}
