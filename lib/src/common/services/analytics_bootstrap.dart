import 'package:flutter/foundation.dart';
import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';

/// Bootstrap analytics initialization
class AnalyticsBootstrap {
  static bool _isInitialized = false;

  /// Initialize analytics
  static Future<void> initialize({
    required AnalyticsEntryPoint entryPoint,
    String? customApiKey,
  }) async {
    if (_isInitialized) {
      AppLogger.w('Analytics already initialized, skipping duplicate initialization');
      return;
    }

    try {
      AppLogger.i('🚀 Starting analytics initialization...');
      AppLogger.i('📍 Entry Point: ${entryPoint.key}');

      // Get PostHog API key
      final apiKey = customApiKey ?? _getPostHogApiKey();

      AppLogger.i(
        '🔑 API Key check: ${apiKey?.isNotEmpty ?? false ? "API key provided" : "NO API KEY FOUND"}',
      );

      // PostHog is optional - continue even if no API key
      final analyticsService = PostHogAnalyticsService();

      AppLogger.i('📡 Calling analytics service init...');
      await analyticsService.init(apiKey: apiKey, entryPoint: entryPoint);

      _isInitialized = true;

      AppLogger.i('✅ Analytics initialized successfully');
      AppLogger.i('📊 Entry Point: ${entryPoint.key}');

      // Track app initialization
      AppLogger.i('📈 Tracking app opened event...');
      await analyticsService.trackAppOpened();
      AppLogger.i('🎯 App opened event tracked successfully');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Analytics initialization failed: $e', e, stackTrace, false);
    }
  }

  /// Get PostHog API key from environment variables
  static String? _getPostHogApiKey() {
    const apiKey = String.fromEnvironment('POSTHOG_MEMVERSE_API_KEY');

    if (apiKey.isEmpty && kDebugMode) {
      AppLogger.w('⚠️ POSTHOG_MEMVERSE_API_KEY not set - PostHog analytics disabled');
      return null;
    }

    if (kDebugMode && apiKey.isNotEmpty) {
      AppLogger.d('🔑 Using PostHog API key (${apiKey.substring(0, 8)}...)');
    }

    return apiKey;
  }

  /// Reset initialization state (for testing)
  static void reset() {
    _isInitialized = false;
  }

  /// Check if analytics is initialized
  static bool get isInitialized => _isInitialized;
}
