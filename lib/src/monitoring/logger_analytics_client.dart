import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import 'analytics_client.dart';

/// A simple implementation of [AnalyticsClient] that logs events to the console.
///
/// This is primarily used in development and testing environments.
class LoggerAnalyticsClient implements AnalyticsClient {
  /// Creates a new [LoggerAnalyticsClient]
  const LoggerAnalyticsClient();

  static const _name = 'Analytics';

  @override
  Future<void> initialize() async {
    log('initialize', name: _name);
    log('Analytics logger initialized in ${kDebugMode ? 'DEBUG' : 'RELEASE'} mode', name: _name);
  }

  @override
  Future<void> setUserId(String? userId) async {
    log('setUserId(userId: ${userId ?? 'null'})', name: _name);
  }

  @override
  Future<void> trackLogin() async {
    log('trackLogin', name: _name);
  }

  @override
  Future<void> trackLogout() async {
    log('trackLogout', name: _name);
  }

  @override
  Future<void> trackSignUp() async {
    log('trackSignUp', name: _name);
  }

  @override
  Future<void> trackVerseSessionStarted() async {
    log('trackVerseSessionStarted', name: _name);
  }

  @override
  Future<void> trackVerseSessionCompleted(int verseCount) async {
    log('trackVerseSessionCompleted(verseCount: $verseCount)', name: _name);
  }

  @override
  Future<void> trackVerseAdded() async {
    log('trackVerseAdded', name: _name);
  }

  @override
  Future<void> trackVerseSearch(String query) async {
    log('trackVerseSearch(query: $query)', name: _name);
  }

  @override
  Future<void> trackVerseRated(int rating) async {
    log('trackVerseRated(rating: $rating)', name: _name);
  }

  @override
  Future<void> trackDashboardView() async {
    log('trackDashboardView', name: _name);
  }

  @override
  Future<void> trackSettingsView() async {
    log('trackSettingsView', name: _name);
  }

  @override
  Future<void> trackSettingChanged(String setting, dynamic value) async {
    log('trackSettingChanged(setting: $setting, value: $value)', name: _name);
  }

  @override
  Future<void> trackAboutView() async {
    log('trackAboutView', name: _name);
  }

  @override
  Future<void> trackError(String errorType, String errorMessage) async {
    log('trackError(errorType: $errorType, errorMessage: $errorMessage)', name: _name);
  }

  @override
  Future<void> trackVerseShared() async {
    log('trackVerseShared', name: _name);
  }

  @override
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? additionalData,
  }) async {
    log('recordError(error: $error, reason: $reason, fatal: $fatal)', name: _name);
    log('Stack trace: ${stackTrace?.toString() ?? 'Not provided'}', name: _name);

    if (additionalData != null) {
      log('Additional data: $additionalData', name: _name);
    }
  }

  @override
  Future<void> logScreenView(String screenName, String screenClass) async {
    log('logScreenView(screenName: $screenName, screenClass: $screenClass)', name: _name);
  }

  @override
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    log(
      'logEvent(eventName: $eventName${parameters != null ? ', parameters: $parameters' : ''})',
      name: _name,
    );
  }
}
