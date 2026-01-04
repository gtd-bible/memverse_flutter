import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/src/app/app.dart';
import 'package:mini_memverse/src/bootstrap.dart';

import 'firebase_options.dart';
import 'services/analytics_manager.dart';

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
  // Make zone errors fatal in debug mode to catch zone mismatches early
  if (kDebugMode) {
    BindingBase.debugZoneErrorsAreFatal = true;
  }

  // Initialize Flutter binding
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Check for required environment variables
  var memverseClientId = const String.fromEnvironment('MEMVERSE_CLIENT_ID');
  final clientSecret = const String.fromEnvironment('MEMVERSE_CLIENT_API_KEY');

  if (kDebugMode) {
    debugPrint('🔍 Checking environment variables:');
    debugPrint(
      '   MEMVERSE_CLIENT_ID: ${memverseClientId.isEmpty ? "❌ MISSING" : "✅ FOUND (${memverseClientId.length} chars)"}',
    );
    debugPrint(
      '   MEMVERSE_CLIENT_API_KEY: ${clientSecret.isEmpty ? "❌ MISSING" : "✅ FOUND (${clientSecret.length} chars)"}',
    );
  }

  // Show error if any required variables are missing
  if (memverseClientId.isEmpty) {
    runApp(
      const ConfigurationErrorWidget(
        error:
            'Missing required MEMVERSE_CLIENT_ID configuration for authentication.\n\n'
            'This value is needed for OAuth authentication.',
      ),
    );
    return;
  }

  if (clientSecret.isEmpty) {
    runApp(
      const ConfigurationErrorWidget(
        error:
            'Missing required MEMVERSE_CLIENT_API_KEY environment variable.\n\n'
            'This value is needed for API authentication.',
      ),
    );
    return;
  }

  try {
    // Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Set up Firebase error handlers
    FlutterError.onError = (errorDetails) {
      AppLogger.e(
        'Flutter error caught by global handler',
        errorDetails.exception,
        errorDetails.stack,
      );
      AnalyticsManager.instance.crashlytics.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.e('Platform error caught by global handler', error, stack);
      AnalyticsManager.instance.crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    // Logging initialization
    AppLogger.i('🌟 App starting with configuration:');
    AppLogger.i(
      '🔐 MEMVERSE_CLIENT_ID: ${memverseClientId.substring(0, 3)}...${memverseClientId.substring(memverseClientId.length - 3)} (${memverseClientId.length} chars)',
    );
    AppLogger.i(
      '🔑 MEMVERSE_CLIENT_API_KEY: ${clientSecret.substring(0, 3)}...${clientSecret.substring(clientSecret.length - 3)} (${clientSecret.length} chars)',
    );
    AppLogger.i('🌍 Using API URL: https://www.memverse.com');
    AppLogger.i('🚀 Firebase Analytics initialized');

    // INTENTIONAL TEST: Create a zone mismatch to test error handling
    runZonedGuarded(
      () async {
        AppLogger.i('⚠️ INTENTIONAL TEST: Running app in a different zone to test error handling');

        // This will cause a zone mismatch since the Flutter binding was initialized in a different zone
        await bootstrap(() => const App());
      },
      (error, stackTrace) {
        // Create a cleaner, more professional error message
        final String cleanErrorMsg =
            'Flutter Zone Mismatch: App initialization and rendering occurred in different zones';
        debugPrint('⚠️ ZONE MISMATCH DETECTED (INTENTIONAL TEST)');
        debugPrint('Error details: $cleanErrorMsg');

        // Create a custom error with a cleaner message
        final customError = FlutterError(cleanErrorMsg);

        // Only log once with our AppLogger - avoid duplicate reports
        AppLogger.error(
          'Zone mismatch detected',
          customError,
          stackTrace,
          true, // recordToCrashlytics = true
          {
            // Custom analytics attributes
            'error_type': 'zone_mismatch',
            'error_source': 'intentional_test',
            'app_state': 'initialization',
            'test_scenario': 'zone_mismatch_test',
            'is_intentional': 'true',
          },
        );
      },
    );
  } catch (error, stackTrace) {
    AppLogger.e('Fatal error during initialization', error, stackTrace);
    if (kDebugMode) {
      debugPrint('💥 FATAL ERROR: $error');
      debugPrint(stackTrace.toString());
    }
    rethrow; // Let the platform handle the fatal error
  }
}
