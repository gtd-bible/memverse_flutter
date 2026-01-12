import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/features/auth/utils/validation_utils.dart';
import 'test_extensions.dart';

void main() {
  group('ValidationUtils', () {
    group('validateUsername', () {
      test('should return null for valid usernames', () {
        expect(ValidationUtils.validateUsername('username123'), isNull);
        expect(ValidationUtils.validateUsername('user.name'), isNull);
        expect(ValidationUtils.validateUsername('user_name'), isNull);
        expect(ValidationUtils.validateUsername('user-name'), isNull);
        expect(ValidationUtils.validateUsername('user@example.com'), isNull);
      });
      
      test('should validate email addresses', () {
        expect(ValidationUtils.validateUsername('test@example.com'), isNull);
        expect(ValidationUtils.validateUsername('test.user@domain.co.uk'), isNull);
        expect(ValidationUtils.validateUsername('test+filter@gmail.com'), isNull);
      });

      test('should return error for empty username', () {
        final result = ValidationUtils.validateUsername('');
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('should return error for username with spaces only', () {
        final result = ValidationUtils.validateUsername('   ');
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('should return error for username that is too short', () {
        final result = ValidationUtils.validateUsername('abc');
        expect(result, isNotNull);
        expect(result, contains('at least'));
      });
      
      test('should trim whitespace before validating', () {
        // This should validate to exactly 4 chars after trimming (minimum required)
        final result = ValidationUtils.validateUsername('  abcd  ');
        expect(result, isNull);
      });
    });

    group('validatePassword', () {
      test('should return null for valid passwords', () {
        expect(ValidationUtils.validatePassword('password123'), isNull);
        expect(ValidationUtils.validatePassword('P@ssw0rd!'), isNull);
        expect(ValidationUtils.validatePassword('12345678'), isNull);
      });

      test('should return error for empty password', () {
        final result = ValidationUtils.validatePassword('');
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('should return error for password with spaces only', () {
        final result = ValidationUtils.validatePassword('   ');
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('should return error for password that is too short', () {
        final result = ValidationUtils.validatePassword('pass');
        expect(result, isNotNull);
        expect(result, contains('at least'));
      });
      
      test('should trim whitespace before validating', () {
        // This should validate to exactly 8 chars after trimming (minimum required)
        final result = ValidationUtils.validatePassword('  password  ');
        expect(result, isNull);
      });
    });
    
    // Parameterized testing for email validation
    group('validateEmailFormat', () {
      final validEmails = [
        'test@example.com',
        'test.name@example.com',
        'test+filter@gmail.com',
        'test@subdomain.example.co.uk',
        'test123@example.com',
        'TEST@EXAMPLE.COM',
        '123@example.com',
      ];
      
      final invalidEmails = [
        '',
        'test',
        'test@',
        '@example.com',
        'test@example',
        'test@.com',
        'test@example..com',
        'test@example.com.',
        '.test@example.com',
        'test..name@example.com',
        'test@example.com@example.com',
        'test@example,com',
        'test example@example.com',
      ];
      
      for (final email in validEmails) {
        test('should validate correct email: $email', () {
          expect(ValidationUtils.validateEmailFormat(email), isNull);
        });
      }
      
      for (final email in invalidEmails) {
        test('should reject invalid email: "$email"', () {
          final result = ValidationUtils.validateEmailFormat(email);
          expect(result, isNotNull);
          expect(result, contains('valid email'));
        });
      }
    });
  });
}