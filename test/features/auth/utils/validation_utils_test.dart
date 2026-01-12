import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/features/auth/utils/validation_utils.dart';

void main() {
  group('ValidationUtils', () {
    group('validateUsername', () {
      test('should return error message for null username', () {
        final result = ValidationUtils.validateUsername(null);
        expect(result, isNotNull);
        expect(result, contains('Please enter your username'));
      });

      test('should return error message for empty username', () {
        final result = ValidationUtils.validateUsername('');
        expect(result, isNotNull);
        expect(result, contains('Please enter your username'));
      });

      test('should return error message for whitespace-only username', () {
        final result = ValidationUtils.validateUsername('   ');
        expect(result, isNotNull);
        expect(result, contains('Please enter your username'));
      });

      test('should return error message for username shorter than 3 characters', () {
        final result = ValidationUtils.validateUsername('ab');
        expect(result, isNotNull);
        expect(result, contains('at least 3 characters'));
      });

      test('should return error message for username longer than 50 characters', () {
        final tooLong = 'a' * 51;
        final result = ValidationUtils.validateUsername(tooLong);
        expect(result, isNotNull);
        expect(result, contains('less than 50 characters'));
      });

      test('should return error message for invalid email format if @ is present', () {
        final result = ValidationUtils.validateUsername('invalid@email');
        expect(result, isNotNull);
        expect(result, contains('valid email address'));
      });

      test('should return null for valid username with exactly 3 characters', () {
        final result = ValidationUtils.validateUsername('abc');
        expect(result, isNull);
      });

      test('should return null for valid username with 50 characters', () {
        final exactlyRight = 'a' * 50;
        final result = ValidationUtils.validateUsername(exactlyRight);
        expect(result, isNull);
      });

      test('should return null for valid username with spaces that trim to valid length', () {
        final result = ValidationUtils.validateUsername('  validuser  ');
        expect(result, isNull);
      });

      test('should return null for valid email format', () {
        final result = ValidationUtils.validateUsername('user@example.com');
        expect(result, isNull);
      });
    });

    group('validatePassword', () {
      test('should return error message for null password', () {
        final result = ValidationUtils.validatePassword(null);
        expect(result, isNotNull);
        expect(result, contains('Please enter your password'));
      });

      test('should return error message for empty password', () {
        final result = ValidationUtils.validatePassword('');
        expect(result, isNotNull);
        expect(result, contains('Please enter your password'));
      });

      test('should return error message for whitespace-only password', () {
        final result = ValidationUtils.validatePassword('   ');
        expect(result, isNotNull);
        expect(result, contains('Please enter your password'));
      });

      test('should return error message for password shorter than 8 characters', () {
        final result = ValidationUtils.validatePassword('short');
        expect(result, isNotNull);
        expect(result, contains('at least 8 characters'));
      });

      test('should return error message for password longer than 100 characters', () {
        final tooLong = 'a' * 101;
        final result = ValidationUtils.validatePassword(tooLong);
        expect(result, isNotNull);
        expect(result, contains('less than 100 characters'));
      });

      test('should return null for valid password with exactly 8 characters', () {
        final result = ValidationUtils.validatePassword('password');
        expect(result, isNull);
      });

      test('should return null for valid password with 100 characters', () {
        final exactlyRight = 'a' * 100;
        final result = ValidationUtils.validatePassword(exactlyRight);
        expect(result, isNull);
      });

      test('should return null for valid password with spaces that trim to valid length', () {
        final result = ValidationUtils.validatePassword('  password123  ');
        expect(result, isNull);
      });
    });

    group('StringValidationExtension', () {
      test('isValidUsername should return true for valid username', () {
        expect('validuser'.isValidUsername, isTrue);
      });

      test('isValidUsername should return false for invalid username', () {
        expect('ab'.isValidUsername, isFalse);
      });

      test('isValidPassword should return true for valid password', () {
        expect('password123'.isValidPassword, isTrue);
      });

      test('isValidPassword should return false for invalid password', () {
        expect('short'.isValidPassword, isFalse);
      });

      test('isValidEmail should return true for valid email', () {
        expect('user@example.com'.isValidEmail, isTrue);
      });

      test('isValidEmail should return false for invalid email', () {
        expect('invalidemail'.isValidEmail, isFalse);
        expect('invalid@email'.isValidEmail, isFalse);
      });

      test('isValidEmail should handle whitespace correctly', () {
        expect('  user@example.com  '.isValidEmail, isTrue);
      });
    });
  });
}
