// lib/core/services/api_exceptions.dart

/// Centralized API error with HTTP status code.
class ApiException implements Exception {
  /// Detailed error message.
  final String message;

  /// HTTP status code (e.g. 400, 401, 500).
  final int statusCode;

  const ApiException(this.message, {required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// 400 Bad Request
  factory ApiException.badRequest(String message) =>
      ApiException(message, statusCode: 400);

  /// 401 Unauthorized
  factory ApiException.unauthorized(String message) =>
      ApiException(message, statusCode: 401);

  /// 403 Forbidden
  factory ApiException.forbidden(String message) =>
      ApiException(message, statusCode: 403);

  /// 404 Not Found
  factory ApiException.notFound(String message) =>
      ApiException(message, statusCode: 404);

  /// 409 Conflict
  factory ApiException.conflict(String message) =>
      ApiException(message, statusCode: 409);

  /// 422 Validation Error
  factory ApiException.validation(String message) =>
      ApiException(message, statusCode: 422);

  /// 500+ Server Error
  factory ApiException.serverError(String message, int code) =>
      ApiException(message, statusCode: code);

  /// No network connectivity
  factory ApiException.network(String message) =>
      ApiException(message, statusCode: 0);

  /// Request timeout
  factory ApiException.timeout(String message) =>
      ApiException(message, statusCode: 0);
}
