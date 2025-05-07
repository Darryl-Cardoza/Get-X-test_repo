import 'package:get_storage/get_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of [AuthRepository] for managing user authentication.
///
/// Handles login via remote API, persists authentication tokens,
/// and configures the API service for authenticated requests.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final GetStorage storage;
  final ApiService apiService;

  /// Constructs the repository with the required dependencies:
  /// - [remote] for remote API calls (e.g., login)
  /// - [storage] for local persistence of token
  /// - [apiService] to inject token for authenticated API usage
  AuthRepositoryImpl({
    required this.remote,
    required this.storage,
    required this.apiService,
  });

  /// Logs in the user and handles JWT token lifecycle.
  ///
  /// Returns `true` on successful login and token setup,
  /// or `false` if login fails due to missing or empty token.
  ///
  /// May throw exceptions if the network call fails or response is invalid.
  @override
  Future<bool> login(String email, String password) async {
    final token = await remote.login(email, password);
    if (token.trim().isEmpty) return false;
    await storage.write(AppConstants.authTokenKey, token);
    apiService.setAuthToken(token);
    return true;
  }
}
