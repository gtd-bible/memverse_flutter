import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/auth/data/fake_auth_service.dart';

void main() {
  group('FakeAuthService', () {
    late FakeAuthService authService;

    setUp(() {
      authService = FakeAuthService();
    });

    group('login', () {
      test('returns true for correct test credentials', () async {
        final result = await authService.login('test', 'password');
        expect(result, true);
        expect(await authService.isAuthenticated(), true);
      });

      test('returns false for incorrect username', () async {
        final result = await authService.login('wrong', 'password');
        expect(result, false);
        expect(await authService.isAuthenticated(), false);
      });

      test('returns false for incorrect password', () async {
        final result = await authService.login('test', 'wrongpassword');
        expect(result, false);
      });

      test('returns false for empty credentials', () async {
        final result = await authService.login('', '');
        expect(result, false);
      });

      test('emits true to auth state stream on successful login', () async {
        final events = <bool>[];
        authService.authStateChanges.listen(events.add);

        await authService.login('test', 'password');
        await Future.delayed(const Duration(milliseconds: 100));

        expect(events, contains(true));
      });

      test('simulates network delay', () async {
        final stopwatch = Stopwatch()..start();
        await authService.login('test', 'password');
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1000));
      });
    });

    group('logout', () {
      test('updates authentication state to false', () async {
        await authService.login('test', 'password');
        expect(await authService.isAuthenticated(), true);

        await authService.logout();

        expect(await authService.isAuthenticated(), false);
      });

      test('emits false to auth state stream', () async {
        await authService.login('test', 'password');
        
        final events = <bool>[];
        authService.authStateChanges.listen(events.add);

        await authService.logout();
        await Future.delayed(const Duration(milliseconds: 600));

        expect(events, contains(false));
      });
    });

    group('isAuthenticated', () {
      test('returns false by default', () async {
        expect(await authService.isAuthenticated(), false);
      });

      test('returns true after successful login', () async {
        await authService.login('test', 'password');
        expect(await authService.isAuthenticated(), true);
      });

      test('returns false after logout', () async {
        await authService.login('test', 'password');
        await authService.logout();
        expect(await authService.isAuthenticated(), false);
      });
    });

    group('authStateChanges stream', () {
      test('broadcasts to multiple listeners', () async {
        final events1 = <bool>[];
        final events2 = <bool>[];
        
        authService.authStateChanges.listen(events1.add);
        authService.authStateChanges.listen(events2.add);

        await authService.login('test', 'password');
        await Future.delayed(const Duration(milliseconds: 100));

        expect(events1, contains(true));
        expect(events2, contains(true));
      });

      test('tracks complete login/logout cycle', () async {
        final events = <bool>[];
        authService.authStateChanges.listen(events.add);

        await authService.login('test', 'password');
        await Future.delayed(const Duration(milliseconds: 100));
        await authService.logout();
        await Future.delayed(const Duration(milliseconds: 600));

        expect(events, [true, false]);
      });
    });

    group('integration scenarios', () {
      test('complete user session flow', () async {
        expect(await authService.isAuthenticated(), false);

        final loginResult = await authService.login('test', 'password');
        expect(loginResult, true);
        expect(await authService.isAuthenticated(), true);

        await authService.logout();
        expect(await authService.isAuthenticated(), false);
      });

      test('failed login does not affect state', () async {
        await authService.login('wrong', 'password');
        expect(await authService.isAuthenticated(), false);

        await authService.login('test', 'password');
        expect(await authService.isAuthenticated(), true);
      });

      test('multiple failed attempts followed by success', () async {
        await authService.login('wrong1', 'password');
        expect(await authService.isAuthenticated(), false);

        await authService.login('wrong2', 'password');
        expect(await authService.isAuthenticated(), false);

        await authService.login('test', 'password');
        expect(await authService.isAuthenticated(), true);
      });
    });

    group('edge cases', () {
      test('case-sensitive password check', () async {
        final result = await authService.login('test', 'Password');
        expect(result, false);
      });

      test('case-sensitive username check', () async {
        final result = await authService.login('Test', 'password');
        expect(result, false);
      });

      test('handles whitespace in credentials', () async {
        final result = await authService.login(' test ', ' password ');
        expect(result, false);
      });
    });
  });
}
