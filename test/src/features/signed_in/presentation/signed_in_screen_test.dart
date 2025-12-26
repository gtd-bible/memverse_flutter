import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/signed_in/presentation/signed_in_screen.dart';

void main() {
  group('SignedInScreen', () {
    Widget buildTestWidget() {
      return const ProviderScope(
        child: MaterialApp(
          home: SignedInScreen(),
        ),
      );
    }

    testWidgets('displays bottom navigation bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('displays all navigation items', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Verse'), findsOneWidget);
      expect(find.text('Ref'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('defaults to the Verse tab', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Verse Text Quiz Placeholder'), findsOneWidget);
      expect(find.text('Home Tab Placeholder'), findsNothing);
    });
  });
}
