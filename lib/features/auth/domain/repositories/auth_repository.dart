/// Defines the contract for authentication operations.
/// Implemented in the data layer.
abstract class AuthRepository {
  /// Attempts to log in with [email] and [password].
  ///
  /// Returns `true` if authentication succeeds, `false` otherwise.
  Future<bool> login(String email, String password);
}
