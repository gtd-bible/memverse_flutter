import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:memverse_flutter/src/services/analytics_service.dart';
import 'package:memverse_flutter/src/utils/app_logger.dart';

part 'analytics_providers.g.dart';

class TalkerAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    AppLogger.i('Event: $name ${parameters ?? ''}');
  }

  @override
  Future<void> setUserId(String? id) async {
    AppLogger.i('User ID: $id');
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    AppLogger.i('User Property: $name = $value');
  }

  @override
  Future<void> logLogin() async {
    AppLogger.i('Event: Login');
  }

  @override
  Future<void> logSignUp() async {
    AppLogger.i('Event: Sign Up');
  }

  @override
  Future<void> logScreenView({required String screenName}) async {
    AppLogger.i('Screen: $screenName');
  }
}

@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  return TalkerAnalyticsService();
}
