import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/features/auth/domain/auth_token.dart';

void main() {
  group('AuthToken', () {
    test('should create token with required fields', () {
      final token = AuthToken(accessToken: 'test_token');

      expect(token.accessToken, equals('test_token'));
      expect(token.tokenType, equals('bearer')); // Default value
      expect(token.scope, equals('user')); // Default value
      expect(token.createdAt, isNotNull); // Should be auto-generated
    });

    test('should create token with all fields', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final token = AuthToken(
        accessToken: 'test_token',
        tokenType: 'custom_type',
        scope: 'admin',
        createdAt: timestamp,
        userId: 123,
      );

      expect(token.accessToken, equals('test_token'));
      expect(token.tokenType, equals('custom_type'));
      expect(token.scope, equals('admin'));
      expect(token.createdAt, equals(timestamp));
      expect(token.userId, equals(123));
    });

    test('should convert to JSON correctly', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final token = AuthToken(
        accessToken: 'test_token',
        tokenType: 'custom_type',
        scope: 'admin',
        createdAt: timestamp,
        userId: 123,
      );

      final json = token.toJson();

      expect(json['access_token'], equals('test_token'));
      expect(json['token_type'], equals('custom_type'));
      expect(json['scope'], equals('admin'));
      expect(json['created_at'], equals(timestamp));
      expect(json['user_id'], equals(123));
    });

    test('should create token from JSON correctly', () {
      final json = {
        'access_token': 'test_token',
        'token_type': 'custom_type',
        'scope': 'admin',
        'created_at': 1642531200,
        'user_id': 123,
      };

      final token = AuthToken.fromJson(json);

      expect(token.accessToken, equals('test_token'));
      expect(token.tokenType, equals('custom_type'));
      expect(token.scope, equals('admin'));
      expect(token.createdAt, equals(1642531200));
      expect(token.userId, equals(123));
    });

    test('should handle missing optional fields in JSON', () {
      final json = {'access_token': 'test_token'};

      final token = AuthToken.fromJson(json);

      expect(token.accessToken, equals('test_token'));
      expect(token.tokenType, equals('bearer')); // Default value
      expect(token.scope, equals('user')); // Default value
      expect(token.createdAt, isNotNull); // Should be auto-generated
      expect(token.userId, isNull); // Not provided
    });

    test('should handle snake_case to camelCase conversion', () {
      final json = {
        'access_token': 'test_token',
        'token_type': 'bearer',
        'refresh_token': 'refresh_value', // Not part of model
        'expires_in': 3600, // Not part of model
      };

      final token = AuthToken.fromJson(json);

      expect(token.accessToken, equals('test_token'));
      expect(token.tokenType, equals('bearer'));
      // Doesn't crash on extra fields
    });

    test('should be able to serialize and deserialize with json encode/decode', () {
      final originalToken = AuthToken(
        accessToken: 'test_token',
        tokenType: 'custom_type',
        scope: 'admin',
        userId: 123,
      );

      final jsonString = json.encode(originalToken.toJson());
      final decodedJson = json.decode(jsonString) as Map<String, dynamic>;
      final restoredToken = AuthToken.fromJson(decodedJson);

      expect(restoredToken.accessToken, equals('test_token'));
      expect(restoredToken.tokenType, equals('custom_type'));
      expect(restoredToken.scope, equals('admin'));
      expect(restoredToken.userId, equals(123));
      expect(restoredToken.createdAt, equals(originalToken.createdAt));
    });

    test('toString contains important fields but not the full token', () {
      final token = AuthToken(accessToken: 'test_token', tokenType: 'bearer');

      final stringRepresentation = token.toString();

      // Should contain important info
      expect(stringRepresentation, contains('AuthToken'));
      expect(stringRepresentation, contains('bearer'));

      // Should not contain the full token for security
      expect(stringRepresentation.contains('test_token'), isFalse);

      // But might contain part of the token
      expect(stringRepresentation, contains('test_'));
    });

    test('const constructor allows compile-time constant instances', () {
      const token1 = AuthToken(accessToken: 'token1');
      const token2 = AuthToken(accessToken: 'token1');

      // Same values should be equal but not identical
      expect(token1 == token2, isTrue);

      // Can be used in const expressions
      const list = [AuthToken(accessToken: 'token1')];
      expect(list, contains(token1));
    });
  });
}
