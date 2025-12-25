import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memverse_flutter/src/app.dart';
import 'package:memverse_flutter/src/utils/app_logger.dart';

// Global ProviderContainer for integration tests
ProviderContainer? globalContainer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase removed - will add back when ready (see STORY-004)
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  globalContainer = ProviderContainer();
  AppLogger.initialize(globalContainer!);

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
