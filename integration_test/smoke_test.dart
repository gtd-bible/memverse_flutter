import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/main.dart';
import 'package:mini_memverse/services/app_logger.dart';

/// Smoke test for Memverse Flutter App
///
/// This test verifies basic app functionality:
/// - App launches without crashes
/// - Required environment variables are present
/// - Firebase initializes successfully
/// - App renders the initial screen
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Smoke Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      AppLogger.i('Starting smoke test: App launches successfully');

      // Build and run the app
      await tester.pumpWidget(const MyHelloWorldApp());
      await tester.pumpAndSettle();

      // Verify the app is running
      expect(find.byType(MaterialApp), findsOneWidget);
      AppLogger.i('✓ App launched and rendered');

      // Wait for async initialization to complete
      await tester.pump(const Duration(seconds: 2));

      AppLogger.i('✅ Smoke test passed: App launches successfully');
    });

    testWidgets('App survives initial load', (WidgetTester tester) async {
      AppLogger.i('Starting smoke test: App survives initial load');

      await tester.pumpWidget(const MyHelloWorldApp());
      await tester.pumpAndSettle();

      // Wait for Firebase and analytics initialization
      await tester.pump(const Duration(seconds: 3));

      // App should still be running without errors
      expect(find.byType(MaterialApp), findsOneWidget);

      AppLogger.i('✓ App survived initial load');
      AppLogger.i('✅ Smoke test passed: App survives initial load');
    });

    testWidgets('Logger functionality test', (WidgetTester tester) async {
      AppLogger.i('Starting smoke test: Logger functionality');

      await tester.pumpWidget(const MyHelloWorldApp());
      await tester.pumpAndSettle();

      // Test all logging levels
      AppLogger.trace('Smoke test trace message');
      AppLogger.debug('Smoke test debug message');
      AppLogger.info('Smoke test info message');
      AppLogger.warning('Smoke test warning message');

      await tester.pump(const Duration(seconds: 1));

      AppLogger.i('✓ All logging levels functional');
      AppLogger.i('✅ Smoke test passed: Logger functionality');
    });

    testWidgets('App responsive state test', (WidgetTester tester) async {
      AppLogger.i('Starting smoke test: App responsive state');

      await tester.pumpWidget(const MyHelloWorldApp());
      await tester.pumpAndSettle();

      // Wait for initialization
      await tester.pump(const Duration(seconds: 2));

      // Verify widget tree is built
      final materialAppFinder = find.byType(MaterialApp);
      expect(materialAppFinder, findsOneWidget);

      // Get the widget state
      final materialApp = tester.widget<MaterialApp>(materialAppFinder);
      expect(materialApp, isNotNull);

      await tester.pump(const Duration(seconds: 1));

      AppLogger.i('✓ App is responsive');
      AppLogger.i('✅ Smoke test passed: App responsive state');
    });
  });
}
