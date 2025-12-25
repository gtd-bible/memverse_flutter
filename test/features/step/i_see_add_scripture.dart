import 'package:flutter_test/flutter_test.dart';
import 'i_see.dart';

/// Usage: I see "Add Scripture"
Future<void> iSeeAddScripture(WidgetTester tester) async {
  await iSee(tester, 'Add Scripture');
}
