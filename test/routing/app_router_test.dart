import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/src/features/auth/domain/auth_state.dart' as auth_domain;
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mini_memverse/src/features/signed_in/presentation/signed_in_nav_scaffold.dart';
import 'package:mini_memverse/src/routing/app_router.dart';
import 'package:mocktail/mocktail.dart';

// Mock the AuthStateNotifier for testing purposes
class MockAuthStateNotifier extends Mock implements auth_domain.AuthStateNotifier {}

void main() {
  group('AppRouter redirect logic', () {
    late MockAuthStateNotifier mockAuthStateNotifier;
    late ProviderContainer container;

    setUp(() {
      mockAuthStateNotifier = MockAuthStateNotifier();
      container = ProviderContainer(
        overrides: [
          // Override the real authStateProvider with our mock
          authStateProvider.overrideWith((ref) => mockAuthStateNotifier),
        ],
      );
    });

    // Test Case 1: Unauthenticated user should be shown the LoginPage
    testWidgets('shows LoginPage when user is unauthenticated', (tester) async {
      // Arrange: Mock the auth state to be unauthenticated (null user)
      when(() => mockAuthStateNotifier.state).thenReturn(const auth_domain.AuthState(user: null));

      // Build the app with the overridden providers
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: goRouter, // Use the real router
          ),
        ),
      );

      // Act: Let the router process the initial route
      await tester.pumpAndSettle();

      // Assert: Verify that the LoginPage is on screen
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(SignedInNavScaffold), findsNothing);
    });

    // Test Case 2: Authenticated user should be shown the SignedInNavScaffold
    testWidgets('shows SignedInNavScaffold when user is authenticated', (tester) async {
      // Arrange: Mock the auth state to be authenticated
      const mockUser = auth_domain.User(id: '1', name: 'test', email: 'test@test.com');
      when(
        () => mockAuthStateNotifier.state,
      ).thenReturn(const auth_domain.AuthState(user: mockUser));

      // Build the app with the overridden providers
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: goRouter),
        ),
      );

      // Act: Let the router process the initial route and settle
      await tester.pumpAndSettle();

      // Assert: Verify that the SignedInNavScaffold is on screen
      expect(find.byType(SignedInNavScaffold), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });
  });
}
