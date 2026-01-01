import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/main.dart';

void main() {
  testWidgets('MyHelloWorldApp widget smoke test', (WidgetTester tester) async {
    // Build the app widget
    await tester.pumpWidget(const MyHelloWorldApp());

    // Verify that the widget was built
    expect(find.byType(MyHelloWorldApp), findsOneWidget);

    // Pump and settle to ensure no exceptions
    await tester.pumpAndSettle();
  });
}
