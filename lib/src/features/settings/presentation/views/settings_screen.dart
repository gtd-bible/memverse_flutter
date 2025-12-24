import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                FirebaseCrashlytics.instance.crash();
              },
              child: const Text('Test Crash'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                try {
                  throw Exception('This is a test Non-Fatal Error');
                } catch (e, s) {
                  FirebaseCrashlytics.instance.recordError(e, s,
                      reason: 'A test non-fatal error occurred');
                }
              },
              child: const Text('Test NFE'),
            ),
          ],
        ),
      ),
    );
  }
}
