// test/domain/usecases/login_usecase_networkinfo_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:getx/core/services/api_exceptions.dart';
import 'package:getx/core/services/network_info.dart';
import 'package:getx/features/auth/domain/repositories/auth_repository.dart';
import 'package:getx/features/auth/domain/usecases/login_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository, NetworkInfo])
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepo;
  late MockNetworkInfo mockNetwork;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockNetwork = MockNetworkInfo();
    useCase = LoginUseCase(
      repository: mockRepo,
      network: mockNetwork,
    );
  });

  test('throws network error when offline', () async {
    when(mockNetwork.isConnected).thenAnswer((_) async => false);

    await expectLater(
      () => useCase.execute('user@example.com', 'Test@123'),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 0)
          .having((e) => e.message, 'message', contains('No internet'))),
    );
  });

  test('throws validation error on invalid email', () async {
    when(mockNetwork.isConnected).thenAnswer((_) async => true);

    await expectLater(
      () => useCase.execute('not-an-email', 'Test@123'),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 422)
          .having(
              (e) => e.message, 'message', contains('Invalid email format'))),
    );
  });

  test('throws validation error on empty password', () async {
    when(mockNetwork.isConnected).thenAnswer((_) async => true);

    await expectLater(
      () => useCase.execute('user@example.com', ''),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 422)
          .having((e) => e.message, 'message',
              contains('Password cannot be empty'))),
    );
  });

  test('trims email before validation and repository call', () async {
    when(mockNetwork.isConnected).thenAnswer((_) async => true);
    when(mockRepo.login('user@example.com', 'Test@123'))
        .thenAnswer((_) async => true);

    final result = await useCase.execute('  user@example.com  ', 'Test@123');
    expect(result, isTrue);
  });

  test('returns true on successful login', () async {
    when(mockNetwork.isConnected).thenAnswer((_) async => true);
    when(mockRepo.login('user@example.com', 'Test@123'))
        .thenAnswer((_) async => true);

    final result = await useCase.execute('user@example.com', 'Test@123');
    expect(result, isTrue);
  });

  test('throws unauthorized on bad credentials', () async {
    when(mockNetwork.isConnected).thenAnswer((_) async => true);
    when(mockRepo.login('user@example.com', 'wrongpass'))
        .thenAnswer((_) async => false);

    await expectLater(
      () => useCase.execute('user@example.com', 'wrongpass'),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 401)
          .having((e) => e.message, 'message',
              contains('Invalid email or password'))),
    );
  });

  test('rethrows ApiException from repository', () async {
    when(mockNetwork.isConnected).thenAnswer((_) async => true);
    when(mockRepo.login(any, any))
        .thenThrow(ApiException.forbidden('Forbidden user'));

    await expectLater(
      () => useCase.execute('user@example.com', 'Test@123'),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 403)
          .having((e) => e.message, 'message', contains('Forbidden user'))),
    );
  });

  test('wraps unexpected errors into serverError', () async {
    when(mockNetwork.isConnected).thenAnswer((_) async => true);
    when(mockRepo.login(any, any)).thenThrow(Exception('boom'));

    await expectLater(
      () => useCase.execute('user@example.com', 'Test@123'),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 500)
          .having((e) => e.message, 'message', contains('Exception: boom'))),
    );
  });
}
