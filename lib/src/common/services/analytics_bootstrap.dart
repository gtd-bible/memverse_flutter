import 'package:mini_memverse/services/app_logger.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';

/// Bootstrap analytics initialization for Firebase Analytics (using only Firebase, PostHog removed)
class AnalyticsBootstrap {
  static bool _isInitialized = false;

  /// Initialize Firebase Analytics
  static Future<void> initialize({required AnalyticsEntryPoint entryPoint}) async {
    if (_isInitialized) {
      AppLogger.w('Analytics already initialized, skipping duplicate initialization');
      return;
    }

    try {
      AppLogger.i('🚀 Starting Firebase Analytics initialization...');
      AppLogger.i('📍 Entry Point: ${entryPoint.key}');

      // Initialize Firebase analytics service
      final analyticsService = FirebaseAnalyticsService();
      await analyticsService.init(entryPoint: entryPoint);

      _isInitialized = true;

      AppLogger.i('✅ Firebase Analytics initialized successfully');
      AppLogger.i('📍 Entry Point: ${entryPoint.key}');

      // Track app initialization
      AppLogger.i('📈 Tracking app opened event...');
      await analyticsService.trackAppOpened();
      AppLogger.i('🎯 App opened event tracked successfully');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Analytics initialization failed: $e', e, stackTrace, false);
    }
  }

  /// Reset initialization state (for testing)
  static void reset() {
    _isInitialized = false;
  }

  /// Check if analytics is initialized
  static bool get isInitialized => _isInitialized;
}
