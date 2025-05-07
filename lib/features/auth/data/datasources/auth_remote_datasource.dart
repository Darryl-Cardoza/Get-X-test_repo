import '../../../../core/services/api_exceptions.dart';
import '../../../../core/services/api_service.dart';

/// Handles authentication-related remote API calls using ApiService.
class AuthRemoteDataSource {
  final ApiService _apiService;

  /// Constructs the data source with the injected [ApiService].
  AuthRemoteDataSource(this._apiService);

  /// Logs in the user with [email] and [password], and returns a JWT token.
  ///
  /// Throws [ApiException] for API-level errors,
  /// or [FormatException] if the response is malformed.
  Future<String> login(String email, String password) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/login',
        body: {'email': email, 'password': password},
      );

      final token = response['token'];
      if (token is! String || token.isEmpty) {
        throw FormatException('Invalid or missing token in login response.');
      }

      // Store token for authenticated requests
      _apiService.setAuthToken(token);

      return token;
    } on ApiException {
      // Propagate known API errors
      rethrow;
    } on FormatException {
      // Let FormatException escape so your tests can catch it
      rethrow;
    } catch (e) {
      // Wrap any other unexpected errors
      throw ApiException('Unexpected login error: $e', statusCode: -1);
    }
  }
}
