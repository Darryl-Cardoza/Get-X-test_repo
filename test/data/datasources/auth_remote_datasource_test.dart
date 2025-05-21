// test/data/datasources/auth_remote_datasource_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:getx/core/services/api_exceptions.dart';
import 'package:getx/core/services/api_service.dart';
import 'package:getx/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_remote_datasource_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late AuthRemoteDataSource dataSource;
  late MockApiService mockApiService;

  const tEmail = 'test@example.com';
  const tPassword = 'Pass@123';
  const tToken = 'jwt_token';

  setUp(() {
    mockApiService = MockApiService();
    dataSource = AuthRemoteDataSource(mockApiService);
  });

  group('login', () {
    test(
        'CRITICAL: returns token and calls setAuthToken when response contains valid token',
        () async {
      // Arrange: stub ApiService.post to return a valid JSON map
      when(mockApiService.post<Map<String, dynamic>>(
        '/login',
        body: {'email': tEmail, 'password': tPassword},
      )).thenAnswer((_) async => {'token': tToken});

      // Act
      final result = await dataSource.login(tEmail, tPassword);

      // Assert
      expect(result, tToken);
      verify(mockApiService.post<Map<String, dynamic>>(
        '/login',
        body: {'email': tEmail, 'password': tPassword},
      )).called(1);
      verify(mockApiService.setAuthToken(tToken)).called(1);
    });

    test(
        'MINOR: throws FormatException when response contains missing or non-string token',
        () async {
      when(mockApiService.post<Map<String, dynamic>>(
        '/login',
        body: anyNamed('body'),
      )).thenAnswer((_) async => {'token': 123}); // non-string

      expect(
        () => dataSource.login(tEmail, tPassword),
        throwsA(isA<FormatException>().having(
            (e) => e.message, 'msg', contains('Invalid or missing token'))),
      );
    });

    test('CRITICAL: rethrows ApiException from ApiService', () async {
      when(mockApiService.post<Map<String, dynamic>>(
        '/login',
        body: anyNamed('body'),
      )).thenThrow(ApiException.forbidden('Forbidden'));

      expect(
        () => dataSource.login(tEmail, tPassword),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'code', 403)),
      );
    });

    test('CRITICAL: wraps unexpected errors into ApiException with statusCode -1',
        () async {
      when(mockApiService.post<Map<String, dynamic>>(
        '/login',
        body: anyNamed('body'),
      )).thenThrow(Exception('boom!'));

      call() => dataSource.login(tEmail, tPassword);

      await expectLater(
        call,
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'code', -1)
            .having((e) => e.message, 'msg',
                contains('Unexpected login error: Exception: boom!'))),
      );
    });
  });
}
