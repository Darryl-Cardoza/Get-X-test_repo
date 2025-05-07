// test/data/repositories/auth_repository_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getx/core/constants/app_constants.dart';
import 'package:getx/core/services/api_service.dart';
import 'package:getx/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:getx/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource, GetStorage, ApiService])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemote;
  late MockGetStorage mockStorage;
  late MockApiService mockApiService;

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockStorage = MockGetStorage();
    mockApiService = MockApiService();
    repository = AuthRepositoryImpl(
      remote: mockRemote,
      storage: mockStorage,
      apiService: mockApiService,
    );
  });

  group('login', () {
    final tEmail = 'user@test.com';
    final tPassword = 'Pass@123';
    final tToken = 'jwt123';

    test('should call remote datasource and save token', () async {
      when(mockRemote.login(tEmail, tPassword)).thenAnswer((_) async => tToken);

      final result = await repository.login(tEmail, tPassword);

      expect(result, true);
      verify(mockRemote.login(tEmail, tPassword));
      verify(mockStorage.write(AppConstants.authTokenKey, tToken));
      verify(mockApiService.setAuthToken(tToken));
    });

    test('should return false if empty token', () async {
      when(mockRemote.login(tEmail, tPassword)).thenAnswer((_) async => '');

      final result = await repository.login(tEmail, tPassword);

      expect(result, false);
      verify(mockRemote.login(tEmail, tPassword));
      verifyNever(mockStorage.write(any, any));
    });

    test('should throw exception on remote error', () async {
      when(mockRemote.login(any, any)).thenThrow(Exception('error'));

      expect(
        () => repository.login(tEmail, tPassword),
        throwsA(isA<Exception>()),
      );
    });
  });
}
