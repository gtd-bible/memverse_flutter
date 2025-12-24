import 'package:talker_flutter/talker_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memverse_flutter/src/utils/talker_provider.dart';

// Define a global instance for convenience if not using Provider everywhere
// or to match the static access pattern from memverse_project.
// In a pure Riverpod app, you'd inject ref.read(talkerProvider)
// or use it directly in widgets/providers.
// For now, let's create a wrapper that uses the talkerProvider for consistency.

class AppLogger {
  static Talker? _talkerInstance;

  static void initialize(ProviderContainer container) {
    _talkerInstance = container.read(talkerProvider);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _talkerInstance?.info(message, error, stackTrace);
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _talkerInstance?.debug(message, error, stackTrace);
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _talkerInstance?.warning(message, error, stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _talkerInstance?.error(message, error, stackTrace);
  }
}
