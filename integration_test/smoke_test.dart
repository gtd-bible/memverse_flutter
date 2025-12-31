import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:memverse/firebase_options.dart';
import 'package:memverse/services/analytics_manager.dart';
import 'package:memverse/services/app_logger.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke Tests - No Mocking', () {
    setUpAll(() async {
      AppLogger.info('Integration smoke test started');
    });

    testWidgets('AnalyticsManager singleton test', (WidgetTester tester) async {
      final manager1 = AnalyticsManager.instance;
      final manager2 = AnalyticsManager.instance;

      expect(manager1, equals(manager2));

      AppLogger.info('Singleton test passed');
    });

    testWidgets('Log analytics event test', (WidgetTester tester) async {
      await tester.pumpAndSettle();

      AnalyticsManager.instance.setIntegrationTestMode(true);

      await AnalyticsManager.instance.logEvent('integration_test_event', {
        'test_name': 'smoke_test',
        'test_action': 'log_event',
      });

      AppLogger.info('Analytics event test passed');
    });

    testWidgets('Full smoke test', (WidgetTester tester) async {
      await tester.pumpAndSettle();

      AnalyticsManager.instance.setIntegrationTestMode(true);

      AppLogger.info('Starting full smoke test');

      expect(AnalyticsManager.instance.isIntegrationTest, isTrue);
      AppLogger.info('✓ Integration test mode is set');

      await AnalyticsManager.instance.logEvent('smoke_test_analytics', {
        'step': '1',
        'test_name': 'full_smoke_test',
      });
      AppLogger.info('✓ Analytics event logged');

      AppLogger.trace('Full smoke test trace');
      AppLogger.debug('Full smoke test debug');
      AppLogger.info('Full smoke test info');
      AppLogger.warning('Full smoke test warning');
      AppLogger.info('✓ Logging at all levels');

      AppLogger.info('✅ Full smoke test completed successfully');
    });

    tearDownAll(() {
      AppLogger.info('Integration smoke test completed');
    });
  });
}