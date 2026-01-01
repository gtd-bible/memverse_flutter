import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/services/app_logger.dart';

void main() {
  group('AppLogger Tests', () {
    test('AppLogger should have all logging methods', () {
      // Verify all static methods exist and are callable
      expect(() => AppLogger.t('test'), returnsNormally);
      expect(() => AppLogger.d('test'), returnsNormally);
      expect(() => AppLogger.i('test'), returnsNormally);
      expect(() => AppLogger.w('test'), returnsNormally);
      expect(() => AppLogger.e('test'), returnsNormally);
    });

    test('AppLogger short form methods should exist', () {
      // Verify passthrough methods exist
      expect(() => AppLogger.debug('test'), returnsNormally);
      expect(() => AppLogger.info('test'), returnsNormally);
      expect(() => AppLogger.warning('test'), returnsNormally);
      expect(() => AppLogger.f('test'), returnsNormally);
    });
  });
}