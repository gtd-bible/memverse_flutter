import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/src/monitoring/crashlytics_talker_observer.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Provider for the Talker logging instance
final talkerProvider = Provider<Talker>((ref) {
  // Initialize with Crashlytics observer for error reporting
  return TalkerFlutter.init(observer: const CrashlyticsTalkerObserver());
});