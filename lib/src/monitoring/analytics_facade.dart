import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_client.dart';
import 'firebase_analytics_client.dart';
import 'logger_analytics_client.dart';

/// Facade class that implements [AnalyticsClient] and delegates calls to all registered clients.
class AnalyticsFacade implements AnalyticsClient {
  /// Creates a new [AnalyticsFacade]
  const AnalyticsFacade(this.clients);

  /// The list of analytics clients to delegate to
  final List<AnalyticsClient> clients;

  @override
  Future<void> trackLogin() => _dispatch((c) => c.trackLogin());

  @override
  Future<void> trackLogout() => _dispatch((c) => c.trackLogout());

  @override
  Future<void> trackSignUp() => _dispatch((c) => c.trackSignUp());

  @override
  Future<void> trackVerseSessionStarted() => _dispatch((c) => c.trackVerseSessionStarted());

  @override
  Future<void> trackVerseSessionCompleted(int verseCount) =>
      _dispatch((c) => c.trackVerseSessionCompleted(verseCount));

  @override
  Future<void> trackVerseAdded() => _dispatch((c) => c.trackVerseAdded());

  @override
  Future<void> trackVerseSearch(String query) => _dispatch((c) => c.trackVerseSearch(query));

  @override
  Future<void> trackVerseRated(int rating) => _dispatch((c) => c.trackVerseRated(rating));

  @override
  Future<void> trackDashboardView() => _dispatch((c) => c.trackDashboardView());

  @override
  Future<void> trackSettingsView() => _dispatch((c) => c.trackSettingsView());

  @override
  Future<void> trackSettingChanged(String setting, dynamic value) =>
      _dispatch((c) => c.trackSettingChanged(setting, value));

  @override
  Future<void> trackAboutView() => _dispatch((c) => c.trackAboutView());

  @override
  Future<void> trackError(String errorType, String errorMessage) =>
      _dispatch((c) => c.trackError(errorType, errorMessage));

  @override
  Future<void> trackVerseShared() => _dispatch((c) => c.trackVerseShared());

  /// Dispatches a call to all registered clients
  Future<void> _dispatch(Future<void> Function(AnalyticsClient client) work) async {
    for (final client in clients) {
      await work(client);
    }
  }
}

/// Provider for Analytics Facade
///
/// In debug mode, only LoggerAnalyticsClient is used.
/// In release mode, both Firebase Analytics and LoggerAnalyticsClient are used.
final analyticsFacadeProvider = Provider<AnalyticsFacade>((ref) {
  final firebaseAnalyticsClient = ref.watch(firebaseAnalyticsClientProvider);
  return AnalyticsFacade([
    if (kReleaseMode) firebaseAnalyticsClient,
    const LoggerAnalyticsClient(),
  ]);
});
