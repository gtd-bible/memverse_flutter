import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/src/app/view/app.dart';
import 'package:mini_memverse/src/bootstrap.dart';
import 'package:mini_memverse/src/common/services/analytics_bootstrap.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';

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
                'Please run the app with proper configuration:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Run with environment variables set (see SETUP.md)',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check for required environment variables
  var clientId = const String.fromEnvironment('CLIENT_ID');
  if (clientId.isEmpty && kDebugMode) {
    clientId = 'debug';
  }

  if (clientId.isEmpty) {
    runApp(
      const ConfigurationErrorWidget(
        error:
            'Missing required CLIENT_ID configuration for authentication.\n\n'
            'Please set MEMVERSE_CLIENT_ID in your shell environment.',
      ),
    );
    return;
  }

  const clientSecret = String.fromEnvironment('MEMVERSE_CLIENT_API_KEY');
  if (clientSecret.isEmpty) {
    runApp(
      const ConfigurationErrorWidget(
        error:
            'Missing required MEMVERSE_CLIENT_API_KEY environment variable.\n\n'
            'Please set MEMVERSE_CLIENT_API_KEY in your shell environment.',
      ),
    );
    return;
  }

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up Firebase error handlers
  FlutterError.onError = (errorDetails) {
    AnalyticsManager.instance.crashlytics.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AnalyticsManager.instance.crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  const autoSignIn = bool.fromEnvironment('AUTOSIGNIN', defaultValue: true);

  if (autoSignIn) {
    AuthService.isDummyUser = true;
  }

  // Logging initialization
  AppLogger.i('🌍 Using API URL: https://www.memverse.com');
  AppLogger.i(
    '🔑 PostHog API Key available: ${const String.fromEnvironment('POSTHOG_MEMVERSE_API_KEY').isNotEmpty}',
  );
  if (kDebugMode) {
    AppLogger.i('🐛 Running in debug mode');
  }

  // Initialize PostHog analytics (works alongside Firebase)
  await AnalyticsBootstrap.initialize(entryPoint: AnalyticsEntryPoint.main);

  // Initialize the app
  await bootstrap(() => const MyHelloWorldApp());
}

class MyHelloWorldApp extends StatelessWidget {
  const MyHelloWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
