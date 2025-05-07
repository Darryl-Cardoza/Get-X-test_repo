// lib/core/services/api_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../global_widgets/app_dialog.dart';
import '../../routes/app_routes.dart';
import '../constants/app_constants.dart';
import 'api_config.dart';
import 'api_exceptions.dart';
import 'storage_service.dart';

/// ApiService handles all HTTP operations, both JSON and multipart:
///  - Connectivity checks before sending requests
///  - Automatic JWT retrieval/injection from secure storage
///  - Retry logic with configurable timeouts
///  - Centralized error mapping and user-facing dialogs for 401
///  - Structured logging using Logger
class ApiService {
  // Underlying HTTP client
  final http.Client _client;
  // Configuration including baseUrl, timeout, retryOptions
  final ApiConfig _config;
  // Connectivity checker to detect offline status
  final Connectivity _connectivity;
  // Logger for request/response/error output
  final Logger _logger;
  // Secure storage service for JWT token
  final StorageService _storage = Get.find<StorageService>();
  // In-memory cache of the JWT to avoid repeated reads
  String? _authToken;

  /// Maps HTTP status codes to exception factories
  final Map<int, ApiException Function(String)> _statusMap = {
    400: (msg) => ApiException.badRequest(msg),
    401: (msg) => ApiException.unauthorized(msg),
    403: (msg) => ApiException.forbidden(msg),
    404: (msg) => ApiException.notFound(msg),
    409: (msg) => ApiException.conflict(msg),
    422: (msg) => ApiException.validation(msg),
  };

  /// Constructor with optional injection of client, connectivity, and logger
  ApiService({
    http.Client? client,
    required ApiConfig config,
    Connectivity? connectivity,
    Logger? logger,
  })  : _client = client ?? http.Client(),
        _config = config,
        _connectivity = connectivity ?? Connectivity(),
        _logger = logger ?? Logger();

  /// Allows manually setting the JWT token (e.g. after login)
  void setAuthToken(String token) => _authToken = token;

  // ------------------------------------------------------------------------
  // PUBLIC JSON METHODS
  // ------------------------------------------------------------------------

  /// Sends a GET request to [path] with optional [parser], [headers], and [queryParams].
  Future<T> get<T>(
    String path, {
    JsonParser<T>? parser,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) =>
      _request(
        'GET',
        path,
        parser: parser,
        headers: headers,
        queryParams: queryParams,
      );

  /// Sends a POST request with optional JSON [body].
  Future<T> post<T>(
    String path, {
    JsonParser<T>? parser,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    Object? body,
  }) =>
      _request(
        'POST',
        path,
        parser: parser,
        headers: headers,
        queryParams: queryParams,
        body: body,
      );

  /// Sends a PUT request with optional JSON [body].
  Future<T> put<T>(
    String path, {
    JsonParser<T>? parser,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    Object? body,
  }) =>
      _request(
        'PUT',
        path,
        parser: parser,
        headers: headers,
        queryParams: queryParams,
        body: body,
      );

  /// Sends a PATCH request with optional JSON [body].
  Future<T> patch<T>(
    String path, {
    JsonParser<T>? parser,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    Object? body,
  }) =>
      _request(
        'PATCH',
        path,
        parser: parser,
        headers: headers,
        queryParams: queryParams,
        body: body,
      );

  /// Sends a DELETE request with optional JSON [body].
  Future<T> delete<T>(
    String path, {
    JsonParser<T>? parser,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    Object? body,
  }) =>
      _request(
        'DELETE',
        path,
        parser: parser,
        headers: headers,
        queryParams: queryParams,
        body: body,
      );

  // ------------------------------------------------------------------------
  // PUBLIC MULTIPART METHODS
  // ------------------------------------------------------------------------

  /// Uploads multipart/form-data to [path], including [fields] and file paths.
  Future<T> multipart<T>(
    String path, {
    JsonParser<T>? parser,
    Map<String, String>? headers,
    Map<String, String>? fields,
    required Map<String, String> files,
  }) async {
    // Check offline
    if (await _connectivity.checkConnectivity() == ConnectivityResult.none) {
      throw ApiException.network('No internet connection.');
    }

    // Build MultipartRequest
    final uri = Uri.parse('${_config.baseUrl}$path');
    final req = http.MultipartRequest('POST', uri)
      ..headers.addAll(await _buildHeaders(headers));

    // Add form fields
    if (fields != null) {
      req.fields.addAll(fields);
    }

    // Attach files
    for (var entry in files.entries) {
      req.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
    }

    _logger.i('→ MULTIPART POST $uri');

    // Send with retry and timeout
    final streamed = await _config.retryOptions.retry(
      () => req.send().timeout(_config.timeout),
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );

    // Convert to Response for parsing
    final resp = await http.Response.fromStream(streamed);
    _logger.i('← ${resp.statusCode}');
    _logger.d('Response: ${resp.body}');

    // Handle unauthorized
    if (resp.statusCode == 401) {
      await _storage.deleteSecure(AppConstants.authTokenKey);
      await AppDialog.show(
        title: 'Session Expired',
        message: 'Please log in again.',
        type: AppDialogType.error,
        confirmText: 'Login',
        onConfirm: () => Get.offAllNamed(AppRoutes.login),
      );
      throw ApiException.unauthorized('Session expired.');
    }

    final parsed = _safeParse(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return parser != null && parsed is Map<String, dynamic>
          ? parser(parsed)
          : parsed as T;
    }
    _handleError(resp.statusCode, resp.body, parsed);
  }

  // ------------------------------------------------------------------------
  // INTERNAL REQUEST PIPELINE
  // ------------------------------------------------------------------------

  Future<T> _request<T>(
    String method,
    String path, {
    JsonParser<T>? parser,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    Object? body,
  }) async {
    // Offline check
    if (await _connectivity.checkConnectivity() == ConnectivityResult.none) {
      throw ApiException.network('No internet connection.');
    }

    // Construct URI including query parameters
    final uri = Uri.parse('${_config.baseUrl}$path').replace(
      queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())),
    );

    // Build headers with JWT injection
    final allHeaders = await _buildHeaders(headers);

    // Log request
    _logger.i('→ $method $uri');
    if (body != null) _logger.d('Body: $body');

    late http.Response resp;
    try {
      // Execute with retry & timeout
      resp = await _config.retryOptions.retry(
        () => _send(method, uri, allHeaders, body).timeout(_config.timeout),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
    } on TimeoutException {
      throw ApiException.timeout('Request to $uri timed out.');
    }

    // Log response
    _logger.i('← ${resp.statusCode}');
    _logger.d('Response: ${resp.body}');

    // Handle 401 unauthorized
    if (resp.statusCode == 401) {
      await _storage.deleteSecure(AppConstants.authTokenKey);
      await AppDialog.show(
        title: 'Session Expired',
        message: 'Please log in again.',
        type: AppDialogType.error,
        confirmText: 'Login',
        onConfirm: () => Get.offAllNamed(AppRoutes.login),
      );
      throw ApiException.unauthorized('Session expired.');
    }

    // Parse JSON safely
    final parsed = _safeParse(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return parser != null && parsed is Map<String, dynamic>
          ? parser(parsed)
          : parsed as T;
    }
    _handleError(resp.statusCode, resp.body, parsed);
  }

  /// Internal: sends HTTP request based on [method].
  Future<http.Response> _send(
    String method,
    Uri uri,
    Map<String, String> headers,
    Object? body,
  ) {
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return _client.put(uri, headers: headers, body: jsonEncode(body));
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return _client.delete(uri, headers: headers, body: jsonEncode(body));
      default:
        throw ApiException('Unsupported HTTP method: \$method', statusCode: 0);
    }
  }

  /// Builds default headers and injects JWT if available.
  Future<Map<String, String>> _buildHeaders(Map<String, String>? extra) async {
    if (_authToken == null) {
      _authToken = await _storage.readSecure(AppConstants.authTokenKey);
      _logger.i('Loaded JWT from secure storage');
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer \$_authToken',
      ...?extra,
    };
  }

  /// Safely parse JSON body or return null.
  dynamic _safeParse(String body) {
    try {
      return body.isNotEmpty ? jsonDecode(body) : null;
    } catch (_) {
      return null;
    }
  }

  /// Maps HTTP errors to ApiException and throws.
  Never _handleError(int code, String raw, dynamic parsed) {
    final msg = (parsed is Map<String, dynamic> && parsed['message'] != null)
        ? parsed['message'] as String
        : raw;
    final factory = _statusMap[code];
    final exception =
        factory != null ? factory(msg) : ApiException.serverError(msg, code);
    throw exception;
  }
}
