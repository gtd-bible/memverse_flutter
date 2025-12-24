import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';
import 'package:memverse_flutter/src/app.dart';
import 'package:memverse_flutter/src/utils/talker_provider.dart';
// import 'package:memverse_flutter/src/features/auth/data/fake_auth_service.dart'; // No longer needed

// Global ProviderContainer for integration tests bypass (similar to memverse_project)
ProviderContainer? globalContainer;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Detect if running in integration test mode via dart-define
  // const isIntegrationTest = bool.fromEnvironment('INTEGRATION_TEST');
  // if (isIntegrationTest) {
  //   // Configuration for dummy user would typically be handled by the AuthService itself
  //   // or via provider overrides in tests.
  // }

  globalContainer = ProviderContainer(); // Initialize without observers first

  // Now add observers which depend on providers
  globalContainer!.observers.add(
    TalkerRiverpodLoggerObserver(talker: globalContainer!.read(talkerProvider)),
  );
  AppLogger.initialize(globalContainer!);


  runApp(
    ProviderScope(
      parent: globalContainer,
      child: const App(),
    ),
  );
}