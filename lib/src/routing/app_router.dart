import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memverse_flutter/src/features/auth/application/auth_providers.dart';
import 'package:memverse_flutter/src/features/auth/presentation/views/login_screen.dart';
import 'package:memverse_flutter/src/features/memverse/presentation/views/home_screen.dart';
import 'package:memverse_flutter/src/features/settings/presentation/views/settings_screen.dart';
import 'package:memverse_flutter/src/common/widgets/tab_scaffold.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:memverse_flutter/src/services/analytics_providers.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final _shellNavigatorKey = GlobalKey<NavigatorState>(); // For nested navigation in ShellRoute

  return GoRouter(
    initialLocation: '/home', // Default for authenticated users
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance), // Add Firebase Analytics Observer
    ],
    routes: [
      // Authentication routes (outside the shell)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(
          onGuestLogin: () {
            // For guest mode, let's navigate to home (or a guest-specific home)
            context.go('/home');
          },
        ),
      ),
      // Authenticated routes (inside the shell)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return TabScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/review', // Placeholder for review/verse quiz
            name: 'review',
            pageBuilder: (context, state) => const NoTransitionPage(child: Center(child: Text('Review Screen Placeholder'))),
          ),
          GoRoute(
            path: '/progress', // Placeholder for progress/stats
            name: 'progress',
            pageBuilder: (context, state) => const NoTransitionPage(child: Center(child: Text('Progress Screen Placeholder'))),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
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
          return '/home'; // Go to home page
        }
        return null; // Stay on current page (if protected) or proceed
      }

      // Keep the user on the splash/loading screen while authentication state is unknown.
      return null;
    },
  );
});