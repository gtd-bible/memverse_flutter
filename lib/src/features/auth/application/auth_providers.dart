import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:memverse_flutter/src/features/auth/data/auth_service.dart';
// import 'package:memverse_flutter/src/features/auth/data/fake_auth_service.dart';
import 'package:memverse_flutter/src/features/auth/data/real_auth_service.dart';

part 'auth_providers.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) {
  // In a real app, this would return a FirebaseAuthService, ApiAuthService, etc.
  return RealAuthService(); // Now using the real service
}

@riverpod
Stream<bool> authStateChanges(AuthStateChangesRef ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}

@riverpod
Future<bool> isAuthenticated(IsAuthenticatedRef ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated();
}
