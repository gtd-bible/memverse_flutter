import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/features/auth/data/auth_api.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/domain/auth_token.dart';
import 'package:mocktail/mocktail.dart';

// Create mock classes
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockAuthApi extends Mock implements AuthApi {}
class MockDio extends Mock implements Dio {}
void main() {
  group('AuthService', () {
    late MockFlutterSecureStorage mockStorage;
    late MockAuthApi mockAuthApi;
    late MockDio mockDio;
    late AuthService authService;

    const testUsername = 'test_user';
    const testPassword = 'test_password';
    const testClientId = 'test_client_id';
    const testClientSecret = 'test_client_secret';

    // Sample token data
    final testToken = AuthToken(
      accessToken: 'test_access_token',
      tokenType: 'Bearer',
      scope: 'read write',
      createdAt: 1234567890,
      userId: 42,
    );

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      mockAuthApi = MockAuthApi();
      mockDio = MockDio();

      authService = AuthService(secureStorage: mockStorage, dio: mockDio, authApi: mockAuthApi);
    });

    group('login', () {
      test('should call API and store token on successful login', () async {
        // Arrange
        when(
          mockAuthApi.getBearerToken(
            'password',
            testUsername,
            testPassword,
            testClientId,
            testClientSecret,
          ),
        ).thenAnswer((_) async => testToken);

        // Act
        final result = await authService.login(
          testUsername,
          testPassword,
          testClientId,
          testClientSecret,
        );

        // Assert
        expect(result, equals(testToken));
        verify(
          mockAuthApi.getBearerToken(
            'password',
            testUsername,
            testPassword,
            testClientId,
            testClientSecret,
          ),
        ).called(1);

        // Verify token is stored
        verify(
          mockStorage.write(key: 'auth_token', value: json.encode(testToken.toJson())),
        ).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/oauth/token'),
          response: Response(
            statusCode: 401,
            data: {'error': 'invalid_grant'},
            requestOptions: RequestOptions(path: '/oauth/token'),
          ),
        );

        when(
          mockAuthApi.getBearerToken(
            'password',
            testUsername,
            testPassword,
            testClientId,
            testClientSecret,
          ),
        ).thenThrow(dioError);

        // Act & Assert
        expect(
          () => authService.login(testUsername, testPassword, testClientId, testClientSecret),
          throwsA(isA<DioException>()),
        );

        // Verify storage is not called
        verifyNever(mockStorage.write(key: 'auth_token', value: any));
      });
    });

    group('logout', () {
      test('should clear token from storage', () async {
        // Act
        await authService.logout();

        // Assert
        verify(mockStorage.delete(key: 'auth_token')).called(1);
      });
    });

    group('isLoggedIn', () {
      test('should return true when token exists in storage', () async {
        // Arrange
        when(
          mockStorage.read(key: 'auth_token'),
        ).thenAnswer((_) async => json.encode(testToken.toJson()));

        // Act
        final result = await authService.isLoggedIn();

        // Assert
        expect(result, isTrue);
        verify(mockStorage.read(key: 'auth_token')).called(1);
      });

      test('should return false when token does not exist', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

        // Act
        final result = await authService.isLoggedIn();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when storage throws exception', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenThrow(Exception('Storage error'));

        // Act
        final result = await authService.isLoggedIn();

        // Assert
        expect(result, isFalse);
      });
    });

    group('getToken', () {
      test('should return token when it exists in storage', () async {
        // Arrange
        when(
          mockStorage.read(key: 'auth_token'),
        ).thenAnswer((_) async => json.encode(testToken.toJson()));

        // Act
        final result = await authService.getToken();

        // Assert
        expect(result?.accessToken, equals(testToken.accessToken));
        expect(result?.tokenType, equals(testToken.tokenType));
      });

      test('should return null when token does not exist', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

        // Act
        final result = await authService.getToken();

        // Assert
        expect(result, isNull);
      });

      test('should return null when stored token is invalid', () async {
        // Arrange
        when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => '{"invalid_json": true');

        // Act
        final result = await authService.getToken();

        // Assert
        expect(result, isNull);
      });
    });
  });
}
