import 'package:get/get.dart';
import 'package:getx/routes/app_routes.dart';

import '../../../../core/utils/validators.dart';
import '../../domain/usecases/login_usecase.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;

  AuthController({required this.loginUseCase});

  // Observables
  final isLoading = false.obs;

  // Text field values (bind from UI if needed)
  final email = ''.obs;
  final password = ''.obs;

  /// Attempts to log in the user after validating inputs.
  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty) {
      _showError('Email cannot be empty');
      return;
    }
    if (!Validators.isEmail(email)) {
      _showError('Invalid email format');
      return;
    }

    if (password.trim().isEmpty) {
      _showError('Password cannot be empty');
      return;
    }
    if (!Validators.isStrongPassword(password)) {
      _showError(
        'Password must be at least 8 characters and include upper, lower, digit, and special character.',
      );
      return;
    }

    isLoading.value = true;
    try {
      final success = await loginUseCase.execute(email.trim(), password.trim());
      if (success) {
        // Navigate to home or dashboard
        Get.offAllNamed(AppRoutes.login);
      } else {
        _showError('Login failed. Please check your credentials.');
      }
    } catch (e) {
      _showError('Something went wrong: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Centralized error handler using snackbar
  void _showError(String message) {
    if (Get.testMode) return;
    Get.snackbar(
      'Login Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
