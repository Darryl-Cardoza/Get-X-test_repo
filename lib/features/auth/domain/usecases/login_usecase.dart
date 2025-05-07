// lib/features/auth/domain/usecases/login_usecase.dart

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/services/network_info.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the "login" business logic.
/// - Validates input
/// - Checks network availability
/// - Delegates to [AuthRepository]
/// - Throws [ApiException] for error cases
class LoginUseCase {
  final AuthRepository _repository;
  final NetworkInfo _network;

  /// [repository] provides authentication calls.
  /// [connectivity] checks network status.
  LoginUseCase({
    required AuthRepository repository,
    required NetworkInfo network,
  })  : _repository = repository,
        _network = network;

  /// Attempts to log in with [email] and [password].
  ///
  /// Returns `true` on success; throws [ApiException] on failure.
  Future<bool> execute(String email, String password) async {
    /// Input validation
    final trimmedEmail = email.trim();
    if (!Validators.isEmail(trimmedEmail)) {
      throw ApiException.validation('Invalid email format');
    }
    if (password.isEmpty) {
      throw ApiException.validation('Password cannot be empty');
    }

    /// Network check
    if (!await _network.isConnected) {
      throw ApiException.network('No internet connection');
    }

    /// Delegate to repository
    try {
      final success = await _repository.login(trimmedEmail, password);
      if (!success) {
        throw ApiException.unauthorized('Invalid email or password');
      }
      return true;
    } on ApiException {
      // Re-throw known API exceptions
      rethrow;
    } catch (e) {
      // 4️⃣ Unexpected errors
      throw ApiException.serverError(e.toString(), 500);
    }
  }
}
