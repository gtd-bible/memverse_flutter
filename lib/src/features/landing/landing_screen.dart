import 'package:flutter/material.dart';
import 'package:memverse_flutter/src/features/demo/presentation/demo_screen.dart';
import 'package:memverse_flutter/src/features/signed_in/presentation/signed_in_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MemVerse App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const DemoScreen(),
                ));
              },
              child: const Text('Go to Demo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SignedInScreen(),
                ));
              },
              child: const Text('Go to Signed-In Experience'),
            ),
          ],
        ),
      ),
    );
  }
}
