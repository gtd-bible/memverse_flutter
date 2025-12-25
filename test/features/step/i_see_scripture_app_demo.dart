import 'package:flutter_test/flutter_test.dart';
import 'i_see.dart';

/// Usage: I see "Scripture App (Demo)"
Future<void> iSeeScriptureAppDemo(WidgetTester tester) async {
  await iSee(tester, 'Scripture App (Demo)');
}
