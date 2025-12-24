import 'package:flutter_test/flutter_test.dart';
import '../utils/test_app_builder.dart';

/// Usage: the app is running
Future<void> theAppIsRunning(WidgetTester tester) async {
  await pumpMockedApp(tester, initialLocation: '/login');
}
