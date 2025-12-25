import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:memverse_flutter/src/services/analytics_service.dart';
import 'package:memverse_flutter/src/utils/app_logger.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
    AppLogger.d('Analytics Event: $name, Parameters: $parameters');
  }

  @override
  Future<void> setUserId(String? id) async {
    await _analytics.setUserId(id: id);
    AppLogger.d('Analytics User ID set: $id');
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    await _analytics.setUserProperty(name: name, value: value);
    AppLogger.d('Analytics User Property set: $name = $value');
  }

  @override
  Future<void> logLogin() async {
    await _analytics.logLogin(loginMethod: 'email'); // Only method currently supported
    AppLogger.d('Analytics Login Event');
  }

  @override
  Future<void> logSignUp() async {
    await _analytics.logSignUp(signUpMethod: 'email'); // Only method currently supported
    AppLogger.d('Analytics Sign Up Event');
  }

  @override
  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
    AppLogger.d('Analytics Screen View: $screenName');
  }
}
