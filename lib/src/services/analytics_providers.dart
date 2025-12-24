import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:memverse_flutter/src/services/analytics_service.dart';
import 'package:memverse_flutter/src/services/firebase_analytics_service.dart';

part 'analytics_providers.g.dart';

@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return FirebaseAnalyticsService();
}
