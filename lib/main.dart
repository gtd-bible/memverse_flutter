import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memverse_flutter/firebase_options.dart';
import 'package:memverse_flutter/src/app.dart';
import 'package:memverse_flutter/src/utils/app_logger.dart';

// Global ProviderContainer for integration tests
ProviderContainer? globalContainer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  globalContainer = ProviderContainer();
  AppLogger.initialize(globalContainer!);

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
