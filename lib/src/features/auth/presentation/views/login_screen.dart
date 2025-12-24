import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback? onGuestLogin;

  const LoginScreen({super.key, this.onGuestLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login'),
            ElevatedButton(
              onPressed: onGuestLogin,
              child: const Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
