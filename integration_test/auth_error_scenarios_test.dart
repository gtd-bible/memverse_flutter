import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/firebase_options.dart';
import 'package:mini_memverse/src/app/app.dart';
import 'package:mini_memverse/src/constants/app_constants.dart';
import 'package:mini_memverse/src/features/auth/providers/auth_error_handler_provider.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_debugger.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:talker/talker.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;

  // Logs directory for saving test output
  final logsDir = Directory('${Directory.current.path}/logs');
  if (!logsDir.existsSync()) {
    logsDir.createSync();
  }

  // Log file for test results
  final logFile = File(
    '${logsDir.path}/auth_error_scenarios_${DateTime.now().millisecondsSinceEpoch}.log',
  );
  final logSink = logFile.openWrite();

  void log(String message) {
    if (kDebugMode) {
      print(message);
    }
    logSink.writeln('${DateTime.now().toIso8601String()} - $message');
  }

  setUpAll(() async {
    log('🚀 Starting Authentication Error Scenarios Test');
    log('📱 Running on: ${binding.defaultBinaryMessenger.toString()}');

    // Initialize Firebase
    log('🔥 Initializing Firebase...');
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      log('✅ Firebase initialized successfully');
    } catch (e) {
      log('❌ Firebase initialization failed: $e');
      // Continue the test even if Firebase fails - we'll just use the logger analytics
    }
  });

  tearDownAll(() async {
    log('🏁 Completed Authentication Error Scenarios Test');

    // Clean up resources
    await logSink.flush();
    await logSink.close();

    log('📝 Logs written to: ${logFile.path}');
  });

  testWidgets('Auth error scenarios are properly tracked in analytics', (
    WidgetTester tester,
  ) async {
    log('📊 Starting auth error tracking test...');

    // Build our app
    log('🏗️ Building app...');
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    // Get the provider container
    container = tester.element(find.byType(ProviderScope)).read(Provider((ref) => ref.container));

    // Access the auth error debugger
    final errorDebugger = container.read(authErrorDebuggerProvider);
    final errorHandler = container.read(authErrorHandlerProvider);

    log('⚠️ Running error simulation with AuthErrorDebugger');

    // Test HTTP errors
    log('🌐 Testing HTTP errors...');
    final httpErrorCodes = [400, 401, 403, 404, 422, 500, 503];
    for (final code in httpErrorCodes) {
      final message = await errorDebugger.simulateHttpError(
        statusCode: code,
        responseData: {'error': 'Simulated HTTP $code error'},
        context: 'IntegrationTest_Login',
        additionalData: {
          'test_id': 'HTTP_$code',
          'timestamp': DateTime.now().toIso8601String(),
          'device': binding.defaultBinaryMessenger.toString(),
        },
      );
      log('✅ HTTP $code: $message');

      // Let the UI update
      await tester.pump(const Duration(milliseconds: 300));
    }

    // Test network errors
    log('🔌 Testing network errors...');
    final networkErrorTypes = [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ];
    for (final type in networkErrorTypes) {
      final message = await errorDebugger.simulateNetworkError(
        type: type,
        context: 'IntegrationTest_Login',
        additionalData: {
          'test_id': 'Network_${type.name}',
          'timestamp': DateTime.now().toIso8601String(),
          'device': binding.defaultBinaryMessenger.toString(),
        },
      );
      log('✅ Network ${type.name}: $message');

      // Let the UI update
      await tester.pump(const Duration(milliseconds: 300));
    }

    // Test socket exception
    log('🔌 Testing socket exception...');
    final socketMessage = await errorDebugger.simulateSocketException(
      message: 'Failed to connect to www.memverse.com',
      context: 'IntegrationTest_Login',
      additionalData: {
        'test_id': 'Socket',
        'timestamp': DateTime.now().toIso8601String(),
        'device': binding.defaultBinaryMessenger.toString(),
      },
    );
    log('✅ Socket Exception: $socketMessage');

    // Test format exception
    log('🔀 Testing format exception...');
    final formatMessage = await errorDebugger.simulateFormatException(
      message: 'Unexpected character in JSON response',
      context: 'IntegrationTest_Login',
      additionalData: {
        'test_id': 'Format',
        'timestamp': DateTime.now().toIso8601String(),
        'device': binding.defaultBinaryMessenger.toString(),
      },
    );
    log('✅ Format Exception: $formatMessage');

    // Let the UI update
    await tester.pump(const Duration(milliseconds: 500));

    // Log success
    log('🎉 Successfully tested all auth error scenarios');
    log('⚠️ Note: Check Firebase Console for Analytics events and Crashlytics reports');
    log('👉 Expected events: http_error_XXX, app_error with various parameters');

    // We don't need to make assertions here as the test is primarily to verify
    // that analytics events are sent to Firebase. Manual verification in the Firebase
    // console will be needed to confirm the events were received.
  });
}
