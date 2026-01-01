import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/firebase_options.dart';
import 'package:mini_memverse/main.dart';
import 'package:mini_memverse/services/analytics_manager.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/src/bootstrap.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';

/// Hello World Integration Test
///
/// This test verifies that:
/// - App launches successfully with proper dart-define variables
/// - Login screen is displayed (not config error screen)
/// - Basic UI elements are present and functional
///
/// Run with:
/// flutter test integration_test/hello_world_test.dart \
///   --dart-define=CLIENT_ID=test_client_id \
///   --dart-define=MEMVERSE_CLIENT_API_KEY=test_api_key \
///   -d emulator-5554
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize once for all tests
    WidgetsFlutterBinding.ensureInitialized();
  });

  group('Hello World Integration Tests', () {
    testWidgets('App launches and shows login screen (not config error)', (
      WidgetTester tester,
    ) async {
      // Verify dart-define variables are set
      var clientId = const String.fromEnvironment('CLIENT_ID');
      if (clientId.isEmpty && kDebugMode) {
        clientId = 'debug';
      }
      const clientSecret = String.fromEnvironment('MEMVERSE_CLIENT_API_KEY');

      // Verify we have the required variables
      expect(clientId.isNotEmpty, true, reason: 'CLIENT_ID should be set via --dart-define');
      expect(
        clientSecret.isNotEmpty,
        true,
        reason: 'MEMVERSE_CLIENT_API_KEY should be set via --dart-define',
      );

      AppLogger.i(
        '✅ Environment variables validated: '
        'CLIENT_ID=$clientId, API_KEY=${clientSecret.substring(0, 8)}...',
      );

      // Initialize Firebase
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      // Set up error handlers
      FlutterError.onError = (errorDetails) {
        AnalyticsManager.instance.crashlytics.recordFlutterFatalError(errorDetails);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        AnalyticsManager.instance.crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      // Don't auto sign in - we want to see the login screen
      AuthService.isDummyUser = false;

      AppLogger.i('🌍 Using API URL: https://www.memverse.com');
      AppLogger.i('🔑 Firebase Analytics initialized');

      // Bootstrap the app
      await bootstrap(() => const MyHelloWorldApp());

      // Give the app time to render
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // CRITICAL CHECK: Verify NO config error screen
      expect(
        find.text('Configuration Error'),
        findsNothing,
        reason: 'Config error should NOT appear when env vars are set',
      );

      AppLogger.i('✅ No configuration error screen - env vars working!');

      // Verify we see the login page instead
      expect(find.byType(LoginPage), findsOneWidget, reason: 'Login page should be displayed');
      expect(find.text('Welcome to Memverse'), findsOneWidget);

      AppLogger.i(
        '✅ Hello World test PASSED: '
        'Login screen displayed correctly with proper env vars!',
      );
    });
  });
}
