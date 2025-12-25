import 'package:flutter_test/flutter_test.dart';
import 'i_see.dart';

/// Usage: I see "Home"
Future<void> iSeeHome(WidgetTester tester) async {
  await iSee(tester, 'Home');
}
