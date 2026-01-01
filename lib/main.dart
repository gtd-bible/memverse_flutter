import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/src/app/view/app.dart';
import 'package:mini_memverse/src/bootstrap.dart';
import 'package:mini_memverse/src/common/services/analytics_bootstrap.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';

import 'firebase_options.dart';
import 'services/analytics_manager.dart';

String _getMemverseApiUrl() {
  const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
  switch (environment) {
    case 'prd':
      return 'https://api.memverse.com';
    case 'stg':
      return 'https://api-stg.memverse.com';
    case 'dev':
    default:
      return 'https://api-dev.memverse.com';
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Web-specific PostHog initialization is handled by analytics service
  if (kIsWeb) {
    AppLogger.i('Web platform detected - PostHog will be initialized by analytics service');
  }

  final apiUrl = _getMemverseApiUrl();
  AppLogger.i('🌍 Using API URL: $apiUrl');
  AppLogger.i(
    '🏷️  Environment: ${const String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev')}',
  );
  AppLogger.i(
    '🔑 PostHog API Key available: ${const String.fromEnvironment('POSTHOG_MEMVERSE_API_KEY').isNotEmpty}',
  );

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
