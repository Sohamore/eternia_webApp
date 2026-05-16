import 'package:flutter/foundation.dart';

class EnvConfig {
  static const String _defaultBaseUrl =
      'https://eternia-ef-prisma.onrender.com/api';

  static String get baseUrl {
    const override = String.fromEnvironment('BASE_URL', defaultValue: '');
    if (override.isEmpty) return _defaultBaseUrl;
    if (_isValidUrl(override)) return override;
    // Log warning and fall back
    debugPrint(
        '[EnvConfig] Invalid BASE_URL override: $override, using default');
    return _defaultBaseUrl;
  }

  static String get environment {
    return const String.fromEnvironment('ENV', defaultValue: 'production');
  }

  static bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
