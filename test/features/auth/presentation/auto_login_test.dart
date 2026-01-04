import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/domain/auth_token.dart';
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockAuthStateNotifier extends StateNotifier<AuthState> with Mock implements AuthNotifier {
  MockAuthStateNotifier() : super(const AuthState());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auto-login tests', () {
    late MockAuthService mockAuthService;
    late MockAnalyticsService mockAnalyticsService;
    late MockAuthStateNotifier mockAuthStateNotifier;

    setUp(() {
      mockAuthService = MockAuthService();
      mockAnalyticsService = MockAnalyticsService();
      mockAuthStateNotifier = MockAuthStateNotifier();

      // Configure mock behavior
      when(() => mockAuthService.isLoggedIn()).thenAnswer((_) async => false);
      when(() => mockAnalyticsService.trackEmptyUsernameValidation()).thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackEmptyPasswordValidation()).thenAnswer((_) async {});
      when(
        () => mockAnalyticsService.trackPasswordVisibilityToggle(any()),
      ).thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackLogin(any())).thenAnswer((_) async {});
      when(() => mockAnalyticsService.trackLoginFailure(any(), any())).thenAnswer((_) async {});

      // Success response for auth service
      final testToken = AuthToken(
        accessToken: 'test_token',
        tokenType: 'Bearer',
        scope: 'user',
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        userId: 123,
      );

      when(
        () => mockAuthService.login(any(), any(), any(), any()),
      ).thenAnswer((_) async => testToken);

      // Mock auth notifier login method
      when(() => mockAuthStateNotifier.login(any(), any())).thenAnswer((_) async {});

      registerFallbackValue(const AuthState());
    });

    testWidgets('Auto-login with long press triggers login', (WidgetTester tester) async {
      // Build widget tree
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            analyticsServiceProvider.overrideWithValue(mockAnalyticsService),
            authStateProvider.notifier.overrideWith((_) => mockAuthStateNotifier),
          ],
          child: const MaterialApp(home: LoginPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify login button is visible
      expect(find.byKey(loginButtonKey), findsOneWidget);

      // Simulate long press on login button
      await tester.longPress(find.byKey(loginButtonKey));
      await tester.pumpAndSettle();

      // Verify login was attempted on the auth notifier
      verify(() => mockAuthStateNotifier.login(any(), any())).called(1);
    });

    // This test is commented out because the auto-login feature was updated to be a hidden
    // easter egg without visual feedback, so we can't test for a snackbar message anymore
    /*
    testWidgets('Auto-login shows snackbar with message', (WidgetTester tester) async {
      // Build widget tree
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
            analyticsServiceProvider.overrideWithValue(mockAnalyticsService),
            authStateProvider.notifier.overrideWith((_) => mockAuthStateNotifier),
          ],
          child: const MaterialApp(home: LoginPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Long press the login button
      await tester.longPress(find.byKey(loginButtonKey));
      await tester.pump(); // Pump once to start the snackbar animation

      // Verify a snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);

      // Verify the snackbar contains text related to logging in
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.textContaining('Logging in with'),
        ),
        findsOneWidget,
      );
    });
    */
  });
}
