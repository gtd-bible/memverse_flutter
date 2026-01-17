import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/common/providers/talker_provider.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/domain/auth_token.dart';
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mini_memverse/src/features/auth/providers/auth_error_handler_provider.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
class MockAuthService extends Mock implements AuthService {}
class MockAnalyticsService extends Mock implements AnalyticsService {}
class MockAnalyticsFacade extends Mock implements AnalyticsFacade {}
class MockAppLoggerFacade extends Mock implements AppLoggerFacade {}
class MockAuthErrorHandler extends Mock implements AuthErrorHandler {}
class MockTalker extends Mock implements Talker {}
class MockLogger extends Mock implements Logger {}

void main() {
  // Set up test infrastructure
  late MockAuthService mockAuthService;
  late MockAnalyticsService mockAnalyticsService;
  late MockAnalyticsFacade mockAnalyticsFacade;
  late MockAppLoggerFacade mockAppLogger;
  late MockAuthErrorHandler mockErrorHandler;
  late ProviderContainer container;
  
  // Define a function to build the Login page with mocked dependencies
  Widget buildLoginPage() {
    return ProviderScope(
      parent: container,
      child: const MaterialApp(
        home: LoginPage(),
      ),
    );
  }

  setUp(() {
    print('Setting up test with mocked dependencies');
    
    // Initialize mocks
    mockAuthService = MockAuthService();
    mockAnalyticsService = MockAnalyticsService();
    mockAnalyticsFacade = MockAnalyticsFacade();
    mockAppLogger = MockAppLoggerFacade();
    mockErrorHandler = MockAuthErrorHandler();
    final mockTalker = MockTalker();
    final mockLogger = MockLogger();
    
    // Configure auth service mock for unhappy path
    when(() => mockAuthService.login(
      any(), 
      any(),
      any(),
      any(),
    )).thenAnswer((_) async {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      print('Auth service mock: simulating login failure');
      // Throw exception to simulate login failure
      throw Exception('Invalid username or password');
    });
    
    // Configure mock logger to avoid null errors
    when(() => mockAppLogger.d(any())).thenReturn(null);
    when(() => mockAppLogger.e(any(), any())).thenReturn(null);
    when(() => mockAppLogger.i(any())).thenReturn(null);
    when(() => mockAppLogger.w(any())).thenReturn(null);
    when(() => mockAppLogger.error(any(), any())).thenReturn(null);
    
    // Configure analytics mocks
    when(() => mockAnalyticsService.trackLoginAttempt(any())).thenAnswer((_) async {});
    when(() => mockAnalyticsService.trackLoginSuccess()).thenAnswer((_) async {});
    when(() => mockAnalyticsService.trackLoginFailure(any(), any())).thenAnswer((_) async {});
    when(() => mockAnalyticsFacade.trackError(any(), any())).thenAnswer((_) async {});
    when(() => mockAnalyticsFacade.logEvent(any(), parameters: any(named: 'parameters'))).thenAnswer((_) async {});
    when(() => mockAnalyticsFacade.recordError(any(), any(), 
        reason: any(named: 'reason'),
        fatal: any(named: 'fatal'),
        additionalData: any(named: 'additionalData'),
    )).thenAnswer((_) async {});
    
    // Configure logger mock
    when(() => mockLogger.e(any())).thenReturn(null);
    
    // Configure error handler mock
    when(() => mockErrorHandler.processError(any(), any(), context: any(named: 'context'), additionalData: any(named: 'additionalData')))
        .thenAnswer((_) async => 'Invalid username or password. Please try again.');

    // Set up Riverpod container with mocks
    container = ProviderContainer(
      overrides: [
        // Override auth service
        authServiceProvider.overrideWithValue(mockAuthService),
        
        // Override other dependencies
        analyticsServiceProvider.overrideWithValue(mockAnalyticsService),
        analyticsFacadeProvider.overrideWithValue(mockAnalyticsFacade),
        appLoggerFacadeProvider.overrideWithValue(mockAppLogger),
        authErrorHandlerProvider.overrideWithValue(mockErrorHandler),
        talkerProvider.overrideWithValue(mockTalker),
      ],
    );
    
    print('Test setup complete');
  });

  tearDown(() {
    container.dispose();
    print('Test cleanup complete');
  });
  
  tearDownAll(() async {
    print('All widget tests completed');
  });

  testWidgets('Login with wrong credentials shows error message', (WidgetTester tester) async {
    print('Starting unhappy path login widget test');
    
    // Build the login page
    print('Building login page widget');
    await tester.pumpWidget(buildLoginPage());
    
    // Wait for the widget to settle
    await tester.pumpAndSettle();
    print('Login page built and ready');
    
    // Verify we're on the login screen
    expect(find.byType(LoginPage), findsOneWidget, reason: 'Login page should be displayed');
    
    // Get login form elements by keys
    final usernameField = find.byKey(const Key('loginUsernameField'));
    final passwordField = find.byKey(const Key('loginPasswordField'));
    final loginButton = find.byKey(const Key('loginButton'));
    
    expect(usernameField, findsOneWidget, reason: 'Username field should be visible');
    expect(passwordField, findsOneWidget, reason: 'Password field should be visible');
    expect(loginButton, findsOneWidget, reason: 'Login button should be visible');
    print('Found all login form elements');
    
    // Enter wrong credentials
    print('Entering credentials: wrongusername / wrongpassword');
    await tester.enterText(usernameField, 'wrongusername');
    await tester.pump(const Duration(milliseconds: 100));
    
    await tester.enterText(passwordField, 'wrongpassword');
    await tester.pump(const Duration(milliseconds: 100));
    
    // Tap login button
    print('Tapping login button...');
    await tester.tap(loginButton);
    
    // First pump to process the tap and start login
    await tester.pump();
    print('Login button tapped');
    
    // Wait for loading indicator to appear
    expect(find.byType(CircularProgressIndicator), findsWidgets, 
      reason: 'Loading indicator should appear during login');
    print('Loading indicator appeared');
    
    // Wait for response and error
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2)); 
    await tester.pump(const Duration(seconds: 1));
    
    // Loading indicator should disappear
    expect(find.byType(CircularProgressIndicator), findsNothing, 
      reason: 'Loading indicator should disappear after login error');
    print('Loading indicator disappeared');
    
    // Check for error message
    final possibleErrorMessages = [
      'Invalid username or password',
      'Authentication failed',
      'Login failed',
      'Incorrect credentials',
    ];
    
    bool errorMessageFound = false;
    String foundMessage = '';
    
    for (final errorText in possibleErrorMessages) {
      if (find.textContaining(errorText).evaluate().isNotEmpty) {
        errorMessageFound = true;
        foundMessage = errorText;
        break;
      }
    }
    
    expect(errorMessageFound, isTrue, 
      reason: 'Should display an error message with wrong credentials');
    print('Error message displayed: "$foundMessage"');
    
    // Verify we're still on login page
    expect(find.byType(LoginPage), findsOneWidget, 
      reason: 'Should remain on login page after failed login');
    print('Still on login page as expected');
    
    // Verify that auth service was called with the correct parameters
    verify(() => mockAuthService.login('wrongusername', 'wrongpassword', any(), any())).called(1);
    print('Auth service was called with correct parameters');
    
    // Verify that analytics service tracked the login failure
    verify(() => mockAnalyticsService.trackLoginAttempt(any())).called(1);
    verify(() => mockAnalyticsService.trackLoginFailure(any(), any())).called(1);
    print('Analytics tracked login attempt and failure');
    
    // Verify error handler was called to process the error
    verify(() => mockErrorHandler.processError(any(), any(), context: any(named: 'context'))).called(1);
    print('Error handler processed the error');
    
    print('Unhappy path login widget test completed successfully!');
  });
}