import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memverse_flutter/src/features/auth/application/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to MemVerse!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authServiceProvider).logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}