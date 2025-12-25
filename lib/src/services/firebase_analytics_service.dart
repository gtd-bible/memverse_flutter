import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:memverse_flutter/src/services/analytics_service.dart';
import 'package:memverse_flutter/src/utils/app_logger.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics, bool isIntegrationTest = false})
      : _analytics = analytics ?? FirebaseAnalytics.instance,
        _isIntegrationTest = isIntegrationTest;

  final FirebaseAnalytics _analytics;
  final bool _isIntegrationTest;

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    // Add integration_test property to all events during integration tests
    final enrichedParams =
        _isIntegrationTest ? {...?parameters, 'integration_test': true} : parameters;

    // Convert Map<String, dynamic> to Map<String, Object> for Firebase
    final Map<String, Object>? convertedParams = enrichedParams?.map(
      (key, value) => MapEntry(key, value as Object),
    );
    await _analytics.logEvent(name: name, parameters: convertedParams);
    AppLogger.d('Analytics Event: $name, Parameters: $enrichedParams');
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
