import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';

void main() {
  testWidgets('shows BuildInfoText with version and build tag', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: LoginPage())));
    // Look for the 'build' tag (could be "alpha build" or "beta build")
    expect(find.textContaining('build'), findsOneWidget);
    // Look for version, starting with "v" (e.g., v1.0.0)
    expect(find.textContaining('v'), findsOneWidget);
  });
}
