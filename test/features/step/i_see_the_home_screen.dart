import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/memverse/presentation/views/home_screen.dart';

Future<void> iSeeTheHomeScreen(WidgetTester tester) async {
  expect(find.byType(HomeScreen), findsOneWidget);
}