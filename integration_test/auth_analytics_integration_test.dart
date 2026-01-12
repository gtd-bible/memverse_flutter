import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mini_memverse/main.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}
class MockAnalyticsFacade extends Mock implements AnalyticsFacade {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAnalyticsService mockAnalyticsService;
  late MockAnalyticsFacade mockAnalyticsFacade;

  setUp(() {
    mockAnalyticsService = MockAnalyticsService();
    mockAnalyticsFacade = MockAnalyticsFacade();
    
    // Set up default mock responses
    when(() => mockAnalyticsService.trackEmptyUsernameValidation()).thenAnswer((_) async {});
    when(() => mockAnalyticsService.trackEmptyPasswordValidation()).thenAnswer((_) async {});
    when(() => mockAnalyticsService.trackInvalidUsernameValidation()).thenAnswer((_) async {});
    when(() => mockAnalyticsService.trackInvalidPasswordValidation()).thenAnswer((_) async {});
    when(() => mockAnalyticsService.trackPasswordVisibilityToggle(any())).thenAnswer((_) async {});
    when(() => mockAnalyticsService.trackLogin(any())).thenAnswer((_) async {});
    when(() => mockAnalyticsService.trackLoginFailure(any(), any())).thenAnswer((_) async {});
    when(() => mockAnalyticsFacade.logEvent(any(), parameters: any(named: 'parameters'))).thenAnswer((_) async {});
    when(() => mockAnalyticsFacade.trackLogin()).thenAnswer((_) async {});
    when(() => mockAnalyticsFacade.setUserId(any())).thenAnswer((_) async {});
    when(() => mockAnalyticsFacade.logScreenView(any(), any())).thenAnswer((_) async {});
    when(() => mockAnalyticsFacade.recordError(
      any(), 
      any(), 
      reason: any(named: 'reason'), 
      fatal: any(named: 'fatal'), 
      additionalData: any(named: 'additionalData'),
    )).thenAnswer((_) async {});
  });

  testWidgets('Authentication with analytics tracking', (WidgetTester tester) async {
    // Build the app with mocked analytics
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsServiceProvider.overrideWithValue(mockAnalyticsService),
          analyticsFacadeProvider.overrideWithValue(mockAnalyticsFacade),
        ],
        child: const App(),
      ),
    );
    
    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Find login page elements
    final usernameField = find.byKey(loginUsernameFieldKey);
    final passwordField = find.byKey(loginPasswordFieldKey);
    final loginButton = find.byKey(loginButtonKey);
    final passwordToggle = find.byKey(passwordVisibilityToggleKey);
    
    // Verify login page is displayed
    expect(usernameField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);
    
    // Test 1: Empty form validation with analytics
    await tester.tap(loginButton);
    await tester.pump();
    
    // Verify analytics tracking for empty username
    verify(() => mockAnalyticsService.trackEmptyUsernameValidation()).called(1);
    
    // Enter username but leave password empty
    await tester.enterText(usernameField, 'testuser');
    await tester.pump();
    await tester.tap(loginButton);
    await tester.pump();
    
    // Verify analytics tracking for empty password
    verify(() => mockAnalyticsService.trackEmptyPasswordValidation()).called(1);
    
    // Test 2: Invalid input validation with analytics
    await tester.enterText(usernameField, 'te'); // Too short
    await tester.enterText(passwordField, 'short'); // Too short
    await tester.pump();
    await tester.tap(loginButton);
    await tester.pump();
    
    // Verify analytics tracking for invalid username
    verify(() => mockAnalyticsService.trackInvalidUsernameValidation()).called(1);
    
    // Fix username but leave password invalid
    await tester.enterText(usernameField, 'validuser');
    await tester.pump();
    await tester.tap(loginButton);
    await tester.pump();
    
    // Verify analytics tracking for invalid password
    verify(() => mockAnalyticsService.trackInvalidPasswordValidation()).called(1);
    
    // Test 3: Password visibility toggle with analytics
    await tester.enterText(passwordField, 'validpassword123');
    await tester.pump();
    
    // Toggle password visibility
    await tester.tap(passwordToggle);
    await tester.pump();
    
    // Verify analytics tracking for password visibility toggle
    verify(() => mockAnalyticsService.trackPasswordVisibilityToggle(true)).called(1);
    
    // Toggle password visibility back
    await tester.tap(passwordToggle);
    await tester.pump();
    
    // Verify analytics tracking for password visibility toggle again
    verify(() => mockAnalyticsService.trackPasswordVisibilityToggle(false)).called(1);
    
    // Test 4: Login attempt tracking
    await tester.enterText(usernameField, 'testuser@example.com');
    await tester.enterText(passwordField, 'password123');
    await tester.pump();
    
    // Tap login button to start login process
    await tester.tap(loginButton);
    await tester.pump();
    
    // Verify login attempt was tracked
    verify(() => mockAnalyticsFacade.logEvent(
      'login_attempt', 
      parameters: any(named: 'parameters'),
    )).called(1);
    
    // Simulate successful login
    final authNotifier = ProviderContainer().read(authStateProvider.notifier);
    
    // In a real app, this would be handled by the auth flow.
    // Here, we're just verifying the analytics integration.
  });
  
  testWidgets('Authentication failure analytics tracking', (WidgetTester tester) async {
    // Build the app with mocked analytics
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsServiceProvider.overrideWithValue(mockAnalyticsService),
          analyticsFacadeProvider.overrideWithValue(mockAnalyticsFacade),
        ],
        child: const App(),
      ),
    );
    
    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Find login page elements
    final usernameField = find.byKey(loginUsernameFieldKey);
    final passwordField = find.byKey(loginPasswordFieldKey);
    final loginButton = find.byKey(loginButtonKey);
    
    // Enter invalid credentials that will be rejected by the server
    await tester.enterText(usernameField, 'invalid@example.com');
    await tester.enterText(passwordField, 'wrongpassword123');
    await tester.pump();
    
    // Tap login button to start login process
    await tester.tap(loginButton);
    await tester.pump();
    
    // Verify login attempt was tracked
    verify(() => mockAnalyticsFacade.logEvent(
      'login_attempt', 
      parameters: any(named: 'parameters'),
    )).called(1);
    
    // In a real integration test with a mock server, we would:
    // 1. Set up the mock server to return 401 error
    // 2. Wait for the error response
    // 3. Verify the login failure was tracked
    
    // For this test, we're just verifying the analytics integration points exist
  });
}