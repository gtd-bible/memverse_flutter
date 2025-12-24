import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memverse_flutter/src/features/auth/application/auth_providers.dart';
import 'package:memverse_flutter/src/features/auth/presentation/views/login_screen.dart';
import 'package:memverse_flutter/src/features/memverse/presentation/views/home_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(
          onGuestLogin: () {
            // This is for guest mode, it might navigate to home directly or to a guest-specific home
            // For now, let's assume it navigates to home
            context.go('/');
          },
        ),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.value;

      // If the user is not authenticated and trying to access a protected route, redirect to login.
      if (isAuthenticated == false) {
        if (state.matchedLocation == '/login') {
          return null; // Already on login page, no redirect needed
        }
        return '/login';
      }

      // If the user is authenticated and trying to access the login page, redirect to home.
      if (isAuthenticated == true) {
        if (state.matchedLocation == '/login') {
          return '/'; // Go to home page
        }
        return null; // Stay on current page (if protected) or proceed
      }

      // Keep the user on the splash/loading screen while authentication state is unknown.
      return null;
    },
  );
});
