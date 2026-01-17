import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/app/app.dart';
import 'package:mini_memverse/src/bootstrap.dart';
import 'package:mini_memverse/src/common/providers/talker_provider.dart';
import 'package:mini_memverse/src/constants/app_constants.dart' as app_constants;
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';

import 'firebase_options.dart';

/// Error widget shown when required configuration is missing
class ConfigurationErrorWidget extends StatelessWidget {
  /// Creates a new ConfigurationErrorWidget
  const ConfigurationErrorWidget({required this.error, super.key});

  /// The error message to display
  final String error;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Configuration Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              const Text(
                'Please run the app with this exact command:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SelectableText(
                  'flutter run \\\n'
                  '  --dart-define=MEMVERSE_CLIENT_ID=\$MEMVERSE_CLIENT_ID \\\n'
                  '  --dart-define=MEMVERSE_CLIENT_API_KEY=\$MEMVERSE_CLIENT_API_KEY',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Make sure these environment variables are set in your shell:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SelectableText(
                  'export MEMVERSE_CLIENT_ID="your_client_id_value"\n'
                  'export MEMVERSE_CLIENT_API_KEY="your_api_key_value"',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'See SETUP.md for more information',
                style: TextStyle(fontSize: 14, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Check required environment variables
  final memverseClientId = app_constants.memverseClientId;
  final clientSecret = app_constants.memverseClientSecret;

  // Simple environment check (until we can generate the EnvChecker class)
  final envCheckPassed =
      memverseClientId.isNotEmpty &&
      clientSecret.isNotEmpty &&
      memverseClientId != "\$MEMVERSE_CLIENT_ID" &&
      clientSecret != "\$MEMVERSE_CLIENT_API_KEY";

  // Show detailed error message if environment variables are missing or invalid
  if (!envCheckPassed) {
    debugPrint('❌ Environment variable check failed! Check logs for details.');

    String errorDetails = 'One or more required environment variables are missing or invalid.\n\n';

    // Build specific error messages based on which variables failed
    if (memverseClientId.isEmpty || memverseClientId == '\$MEMVERSE_CLIENT_ID') {
      errorDetails +=
          '• MEMVERSE_CLIENT_ID: ${memverseClientId.isEmpty ? "Missing" : "Unsubstituted"}\n';
    }

    if (clientSecret.isEmpty || clientSecret == '\$MEMVERSE_CLIENT_API_KEY') {
      errorDetails +=
          '• MEMVERSE_CLIENT_API_KEY: ${clientSecret.isEmpty ? "Missing" : "Unsubstituted"}\n';
    }

    errorDetails +=
        '\nPossible causes:\n'
        '1. Environment variables not defined in your shell\n'
        '2. Forgot to use --dart-define flags\n'
        '3. Using literal \$ variables instead of actual values\n';

    runApp(ConfigurationErrorWidget(error: errorDetails));
    return;
  }

  try {
    // Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Create a ProviderContainer to access providers
    final container = ProviderContainer();

    // Get the analytics facade for error tracking
    final analyticsFacade = container.read(analyticsFacadeProvider);

    // Get the logger facade
    final appLogger = container.read(appLoggerFacadeProvider);

    // Get the talker instance
    final talker = container.read(talkerProvider);

    // Set up error handlers
    FlutterError.onError = (errorDetails) {
      // Log the error with our logger facade
      appLogger.error(
        'Flutter error caught by global handler',
        errorDetails.exception,
        errorDetails.stack,
        true, // record to crashlytics
        {
          'error_context': 'FlutterError.onError',
          'library': errorDetails.library ?? 'unknown',
          'context': errorDetails.context?.toString() ?? 'unknown',
        },
      );

      // Also send to talker for UI display
      talker.handle(errorDetails.exception, errorDetails.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      // Log the fatal error with our logger facade
      appLogger.fatal('Platform error caught by global handler', error, stack, {
        'error_context': 'PlatformDispatcher.onError',
      });

      // Also send to talker for UI display
      talker.handle(error, stack);

      return true;
    };

    // Log initialization success
    appLogger.i('🌟 App starting with configuration:');
    appLogger.i(
      '🔐 MEMVERSE_CLIENT_ID: ${memverseClientId.substring(0, 3)}...${memverseClientId.substring(memverseClientId.length - 3)} (${memverseClientId.length} chars)',
    );
    appLogger.i(
      '🔑 MEMVERSE_CLIENT_API_KEY: ${clientSecret.substring(0, 3)}...${clientSecret.substring(clientSecret.length - 3)} (${clientSecret.length} chars)',
    );
    appLogger.i('🌍 Using API URL: https://www.memverse.com');
    appLogger.i('🚀 Firebase Analytics initialized');

    // Initialize the app with Riverpod
    await bootstrap(() => const App());
  } catch (error, stackTrace) {
    // Fall back to direct logging if our logger setup fails
    if (kDebugMode) {
      debugPrint('💥 FATAL ERROR: $error');
      debugPrint(stackTrace.toString());
    }

    // Try to record to crashlytics directly as a last resort
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Fatal initialization error',
      );
    } catch (e) {
      // Nothing more we can do - this is a catastrophic failure
      if (kDebugMode) {
        debugPrint('💥 CATASTROPHIC: Failed to report initialization error: $e');
      }
    }

    // Let the platform handle the fatal error
    rethrow;
  }
}
