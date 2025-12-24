import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/auth/presentation/views/login_screen.dart';
import 'package:memverse_flutter/src/features/memverse/presentation/views/home_screen.dart';
import '../utils/test_app.dart';

Future<void> theAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(
    TestApp(
      home: Builder(
        builder: (context) {
          return LoginScreen(
            onGuestLogin: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          );
        },
      ),
    ),
  );
}