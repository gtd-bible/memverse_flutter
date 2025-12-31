import 'package:flutter_test/flutter_test.dart';
import 'package:memverse/services/analytics_manager.dart';

void main() {
  group('AnalyticsManager Singleton', () {
    test('should return same instance', () {
      final instance1 = AnalyticsManager.instance;
      final instance2 = AnalyticsManager.instance;
      expect(instance1, equals(instance2));
    });
  });

  group('AnalyticsManager - Integration Test Mode', () {
    test('should set integration test mode to true', () {
      final manager = AnalyticsManager.instance;
      manager.setIntegrationTestMode(true);
      expect(manager.isIntegrationTest, isTrue);
    });

    test('should set integration test mode to false', () {
      final manager = AnalyticsManager.instance;
      manager.setIntegrationTestMode(false);
      expect(manager.isIntegrationTest, isFalse);
    });

    test('should toggle integration test mode', () {
      final manager = AnalyticsManager.instance;
      manager.setIntegrationTestMode(true);
      expect(manager.isIntegrationTest, isTrue);
      manager.setIntegrationTestMode(false);
      expect(manager.isIntegrationTest, isFalse);
      manager.setIntegrationTestMode(true);
      expect(manager.isIntegrationTest, isTrue);
    });
  });
}
