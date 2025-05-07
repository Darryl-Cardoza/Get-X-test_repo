// lib/core/services/api_config.dart

import 'package:retry/retry.dart';

/// Holds base URL, timeout, and retry strategy.
class ApiConfig {
  /// e.g. 'https://api.yourdomain.com'
  final String baseUrl;

  /// Maximum waiting time per request
  final Duration timeout;

  /// Number of retries + backoff
  final RetryOptions retryOptions;

  ApiConfig({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    RetryOptions? retryOptions,
  }) : retryOptions = retryOptions ??
            RetryOptions(
                maxAttempts: 3, delayFactor: const Duration(seconds: 2));
}

/// Typedef for JSON parsing callbacks.
typedef JsonParser<T> = T Function(Map<String, dynamic> json);
