abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});
  Future<void> setUserId(String? id);
  Future<void> setUserProperty(String name, String? value);
  Future<void> logLogin({String? loginMethod});
  Future<void> logSignUp({String? signUpMethod});
  Future<void> logScreenView({required String screenName});
}
