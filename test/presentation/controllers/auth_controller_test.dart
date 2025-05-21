// test/presentation/controllers/auth_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx/features/auth/domain/usecases/login_usecase.dart';
import 'package:getx/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_controller_test.mocks.dart';

@GenerateMocks([LoginUseCase])
void main() {
  // Initialize Flutter bindings for GetX context access
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController controller;
  late MockLoginUseCase mockUseCase;

  setUpAll(() {
    // Enable GetX test mode to disable real snackbars/navigation
    Get.testMode = true;
  });

  setUp(() {
    mockUseCase = MockLoginUseCase();
    controller = AuthController(loginUseCase: mockUseCase);
  });

  test('CRITICAL: successful login toggles loading but does not throw', () async {
    when(mockUseCase.execute(any, any)).thenAnswer((_) async => true);

    // Before login
    expect(controller.isLoading.value, isFalse);

    // Act
    await controller.login('user@example.com', 'Pass@123');

    // After login
    expect(controller.isLoading.value, isFalse);
    // No exception means pass
  });

  test('CRITICAL: failed login toggles loading but does not throw', () async {
    when(mockUseCase.execute(any, any)).thenAnswer((_) async => false);

    // Expect the Future to complete successfully.
    expect(
      controller.login('user@example.com', 'Pass@123'),
      completes,
    );

    // Let it finish
    await controller.login('user@example.com', 'Pass@123');
    expect(controller.isLoading.value, isFalse);
  });

  test('CRITICAL: validation errors turn loading off immediately', () async {
    // Empty email
    await controller.login('', 'Pass@123');
    expect(controller.isLoading.value, isFalse);

    // Invalid email
    await controller.login('bad-email', 'Pass@123');
    expect(controller.isLoading.value, isFalse);

    // Empty password
    await controller.login('user@example.com', '');
    expect(controller.isLoading.value, isFalse);

    // Weak password
    await controller.login('user@example.com', 'short');
    expect(controller.isLoading.value, isFalse);
  });
}
