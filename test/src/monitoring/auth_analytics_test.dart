import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mini_memverse/src/monitoring/firebase_analytics_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

// Mock classes
class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

class MockTalker extends Mock implements Talker {}

void main() {
  late MockFirebaseAnalytics analytics;
  late MockFirebaseCrashlytics crashlytics;
  late FirebaseAnalyticsClient analyticsClient;
  late AnalyticsFacade analyticsFacade;

  // Test data
  const testUserId = '12345';
  final testException = Exception('Auth failed: Invalid credentials');
  final testStackTrace = StackTrace.current;

  setUp(() {
    analytics = MockFirebaseAnalytics();
    crashlytics = MockFirebaseCrashlytics();

    // Initialize with our mock instances
    analyticsClient = FirebaseAnalyticsClient(analytics, crashlytics);

    // Create the facade with just our test client
    analyticsFacade = AnalyticsFacade([analyticsClient]);

    // Set up default responses
    when(() => analytics.setUserId(id: any(named: 'id'))).thenAnswer((_) async {});
    when(() => analytics.logLogin(loginMethod: any(named: 'loginMethod'))).thenAnswer((_) async {});
    when(
      () => analytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
    when(() => crashlytics.setUserIdentifier(any())).thenAnswer((_) async {});
    when(
      () => crashlytics.recordError(
        any(),
        any(),
        reason: any(named: 'reason'),
        fatal: any(named: 'fatal'),
      ),
    ).thenAnswer((_) {});
    when(() => crashlytics.setCustomKey(any(), any())).thenAnswer((_) {});
  });

  group('Authentication Analytics Tests -', () {
    // Logging detailed test steps for verification
    void logTestStep(String step) {
      print('🔍 TEST: $step');
    }

    test('Successful login flow should track all required events', () async {
      logTestStep('Testing successful login analytics flow');

      // First, verify login attempt is logged
      await analyticsFacade.logEvent(
        'login_attempt',
        parameters: {'has_username': true, 'username_length': 10},
      );

      verify(
        () => analytics.logEvent(
          name: 'login_attempt',
          parameters: {'has_username': true, 'username_length': 10},
        ),
      ).called(1);

      logTestStep('Login attempt event verified');

      // Then verify standard login event
      await analyticsFacade.trackLogin();

      verify(() => analytics.logLogin()).called(1);
      logTestStep('Standard login event verified');

      // Finally verify the success event with user data
      await analyticsFacade.logEvent(
        'login_success',
        parameters: {'user_id': testUserId, 'token_type': 'Bearer', 'authenticated': true},
      );

      verify(
        () => analytics.logEvent(
          name: 'login_success',
          parameters: {'user_id': testUserId, 'token_type': 'Bearer', 'authenticated': true},
        ),
      ).called(1);

      logTestStep('Login success event with user data verified');

      // Verify user ID is set
      await analyticsFacade.setUserId(testUserId);

      verify(() => analytics.setUserId(id: testUserId)).called(1);
      verify(() => crashlytics.setUserIdentifier(testUserId)).called(1);

      logTestStep('User ID set in both Analytics and Crashlytics');
    });

    test('Failed login should track errors properly', () async {
      logTestStep('Testing failed login error tracking');

      // Track the auth error
      await analyticsFacade.trackError('auth_error', 'Login failed: Invalid credentials');

      verify(
        () => analytics.logEvent(
          name: 'app_error',
          parameters: {
            'error_type': 'auth_error',
            'error_message': 'Login failed: Invalid credentials',
          },
        ),
      ).called(1);

      logTestStep('Auth error event verified');

      // Record the error with full context
      await analyticsFacade.recordError(
        testException,
        testStackTrace,
        reason: 'Login failure',
        fatal: false,
        additionalData: {
          'username_provided': true,
          'username_length': 10,
          'client_id_provided': true,
          'client_secret_provided': true,
        },
      );

      // Verify error recorded in Crashlytics
      verify(
        () => crashlytics.recordError(
          testException,
          testStackTrace,
          reason: 'Login failure',
          fatal: false,
        ),
      ).called(1);

      // Verify custom keys set
      verify(() => crashlytics.setCustomKey('username_provided', 'true')).called(1);
      verify(() => crashlytics.setCustomKey('username_length', '10')).called(1);
      verify(() => crashlytics.setCustomKey('client_id_provided', 'true')).called(1);
      verify(() => crashlytics.setCustomKey('client_secret_provided', 'true')).called(1);

      // Verify analytics error event
      verify(
        () => analytics.logEvent(
          name: 'app_error',
          parameters: any(named: 'parameters'),
        ),
      ).called(2); // Once from trackError, once from recordError

      logTestStep('Error recording with full context verified');
    });

    test('Empty token response should track appropriate events', () async {
      logTestStep('Testing empty token response tracking');

      await analyticsFacade.logEvent(
        'login_empty_token',
        parameters: {'has_username': true, 'authenticated': false},
      );

      verify(
        () => analytics.logEvent(
          name: 'login_empty_token',
          parameters: {'has_username': true, 'authenticated': false},
        ),
      ).called(1);

      logTestStep('Empty token event verified');
    });

    test('Logout should track appropriate events', () async {
      logTestStep('Testing logout tracking');

      await analyticsFacade.trackLogout();

      verify(() => analytics.logEvent(name: 'logout')).called(1);

      await analyticsFacade.logEvent(
        'user_logout',
        parameters: {'user_id': testUserId, 'session_active': true},
      );

      verify(
        () => analytics.logEvent(
          name: 'user_logout',
          parameters: {'user_id': testUserId, 'session_active': true},
        ),
      ).called(1);

      logTestStep('Logout events verified');

      // Verify user ID is cleared on logout
      await analyticsFacade.setUserId(null);

      verify(() => analytics.setUserId(id: null)).called(1);
      verify(() => crashlytics.setUserIdentifier('')).called(1);

      logTestStep('User ID cleared in both Analytics and Crashlytics');
    });
  });
}
