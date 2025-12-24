import 'dart:async';

import 'package:memverse_flutter/src/features/auth/data/auth_service.dart';

class FakeAuthService implements AuthService {
  bool _isAuthenticated = false;
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  @override
  Future<bool> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    if (username == 'test' && password == 'password') {
      _isAuthenticated = true;
      _authStateController.add(true);
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 500));
    _isAuthenticated = false;
    _authStateController.add(false);
  }

  @override
  Future<bool> isAuthenticated() async {
    return _isAuthenticated;
  }

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;
}
