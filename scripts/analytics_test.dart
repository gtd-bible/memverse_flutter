import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// A simple command-line script to test Firebase Analytics and Crashlytics
///
/// This script sends test events to Firebase and verifies they're properly received
/// Usage: dart run scripts/analytics_test.dart
Future<void> main() async {
  // Create a log file
  final logFile = File('analytics_test_results_${DateTime.now().millisecondsSinceEpoch}.log');
  final logSink = logFile.openWrite();

  void log(String message) {
    logSink.writeln('[${DateTime.now()}] $message');
    print(message);
  }

  try {
    log('🚀 Starting Firebase Analytics and Crashlytics test...');

    // Initialize Firebase
    await Firebase.initializeApp();
    log('✅ Firebase initialized');

    final analytics = FirebaseAnalytics.instance;
    final crashlytics = FirebaseCrashlytics.instance;

    // Configure collection based on options
    bool enableCollection = true; // Set to false to disable for testing
    await analytics.setAnalyticsCollectionEnabled(enableCollection);
    await crashlytics.setCrashlyticsCollectionEnabled(enableCollection);

    log('📊 Analytics collection enabled: $enableCollection');
    log('🔥 Crashlytics collection enabled: $enableCollection');

    // Set user properties
    final testUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
    await analytics.setUserId(id: testUserId);
    await crashlytics.setUserIdentifier(testUserId);

    log('👤 Set test user ID: $testUserId');

    // Set a custom user property
    await analytics.setUserProperty(name: 'test_group', value: 'analytics_test');
    crashlytics.setCustomKey('test_group', 'analytics_test');

    log('🔑 Set custom user property: test_group = analytics_test');

    // Send standard events
    log('📤 Sending standard events...');

    // Login event
    await analytics.logLogin(loginMethod: 'test_script');
    log('  - Sent login event');

    // Screen view event
    await analytics.logScreenView(screenName: 'test_screen', screenClass: 'TestScreen');
    log('  - Sent screen view event: test_screen');

    // Custom event with parameters
    await analytics.logEvent(
      name: 'test_custom_event',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
        'test_param1': 'value1',
        'test_param2': 42,
      },
    );
    log('  - Sent custom event: test_custom_event');

    // Test non-fatal error reporting
    log('📤 Testing non-fatal error reporting...');
    try {
      throw Exception('Test non-fatal exception from analytics_test.dart');
    } catch (e, stack) {
      // Set custom keys for better analysis
      crashlytics.setCustomKey('error_source', 'analytics_test.dart');
      crashlytics.setCustomKey('error_type', 'non_fatal');
      crashlytics.setCustomKey('timestamp', DateTime.now().toIso8601String());

      // Record the error
      await crashlytics.recordError(e, stack, reason: 'Test non-fatal error', fatal: false);

      // Also log to analytics
      await analytics.logEvent(
        name: 'test_error',
        parameters: {
          'error': e.toString(),
          'fatal': false,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      log('  - Recorded non-fatal error: ${e.toString()}');
    }

    log('✅ Test completed successfully!');
    log('📋 Check your Firebase console for these events');
    log('   - Analytics: https://console.firebase.google.com/project/_/analytics/overview');
    log('   - Crashlytics: https://console.firebase.google.com/project/_/crashlytics');

    log('🔍 It may take a few minutes for events to appear in the console');

    // Log results path
    log('📝 Test results written to: ${logFile.absolute.path}');
  } catch (e, stack) {
    log('❌ Test failed with error: $e');
    log('Stack trace: $stack');
  } finally {
    // Close the log sink
    await logSink.close();
  }
}
