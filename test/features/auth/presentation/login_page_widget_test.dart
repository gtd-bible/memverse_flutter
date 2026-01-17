import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/common/providers/talker_provider.dart';
import 'package:mini_memverse/src/common/services/analytics_service.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/presentation/login_page.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mini_memverse/src/features/auth/providers/auth_error_handler_provider.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker/talker.dart';

// We need a tracked analytics service for verification
class TrackedAnalyticsService implements AnalyticsService {
  int trackEmptyUsernameValidationCalls = 0;
  int trackEmptyPasswordValidationCalls = 0;
  int trackInvalidUsernameValidationCalls = 0;
  int trackInvalidPasswordValidationCalls = 0;
  List<bool> passwordVisibilityToggles = [];
  List<String> loginUsernames = [];

  @override
  Future<void> init({AnalyticsEntryPoint? entryPoint}) async {}

  @override
  Future<void> track(String eventName, {Map<String, dynamic>? properties}) async {}

  @override
  Future<void> trackEmptyUsernameValidation() async {
    trackEmptyUsernameValidationCalls++;
  }

  @override
  Future<void> trackEmptyPasswordValidation() async {
    trackEmptyPasswordValidationCalls++;
  }

  @override
  Future<void> trackInvalidUsernameValidation() async {
    trackInvalidUsernameValidationCalls++;
  }

  @override
  Future<void> trackInvalidPasswordValidation() async {
    trackInvalidPasswordValidationCalls++;
  }

  @override
  Future<void> trackPasswordVisibilityToggle(bool isVisible) async {
    passwordVisibilityToggles.add(isVisible);
  }

  @override
  Future<void> trackLogin(String username) async {
    loginUsernames.add(username);
  }

  @override
  Future<void> trackLogout() async {}

  @override
  Future<void> trackLoginFailure(String username, String error) async {}

  @override
  Future<void> trackAppOpened() async {}

  @override
  Future<void> trackAnalyticsInitialized() async {}

  @override
  Future<void> trackFeedbackTrigger() async {}

  @override
  Future<void> trackPracticeSessionComplete(int versesAnswered, int correctAnswers) async {}

  @override
  Future<void> trackPracticeSessionStart() async {}

  @override
  Future<void> trackValidationFailure(String field, String error) async {}

  @override
  Future<void> trackVerseApiFailure(String errorType, String errorMessage) async {}

  @override
  Future<void> trackVerseApiSuccess(int verseCount, int responseTime) async {}

  @override
  Future<void> trackVerseCorrect(String verseReference) async {}

  @override
  Future<void> trackVerseDisplayed(String verseReference) async {}

  @override
  Future<void> trackVerseIncorrect(String verseReference, String userAnswer) async {}

  @override
  Future<void> trackVerseListCycled(int totalVerses, int cycleCount) async {}

  @override
  Future<void> trackVerseNearlyCorrect(String verseReference, String userAnswer) async {}

  @override
  Future<void> trackWebBrowserInfo(String userAgent) async {}

  @override
  Future<void> trackWebPageView(String pageName) async {}

  @override
  Future<void> trackWebPerformance(int loadTime, String pageName) async {}
}

// Regular mock classes for other services
class MockAuthService extends Mock implements AuthService {}

class MockAnalyticsFacade extends Mock implements AnalyticsFacade {}

class MockTalker extends Mock implements Talker {}

class MockAppLoggerFacade extends Mock implements AppLoggerFacade {}

class MockAuthErrorHandler extends Mock implements AuthErrorHandler {}

// Tracked auth notifier for verification
class TrackedAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  TrackedAuthNotifier() : super(const AuthState()) {
    // Initialize required fields
    _authService = MockAuthService();
    _clientId = 'test_client_id';
    _clientSecret = 'test_client_secret';
    _analyticsService = TrackedAnalyticsService();
    _analyticsFacade = MockAnalyticsFacade();
    _talker = MockTalker();
    _appLogger = MockAppLoggerFacade();
    _errorHandler = MockAuthErrorHandler();
  }

  final List<Map<String, String>> loginCalls = [];

  @override
  Future<void> login(String username, String password) async {
    loginCalls.add({'username': username, 'password': password});
    state = state.copyWith(isLoading: true, error: null);
    // Don't use Future.delayed as it causes pending timers in tests
    state = state.copyWith(isLoading: false);
  }

  @override
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 10));
    state = const AuthState();
  }

  // Implementing the required members from AuthNotifier
  @override
  late final AuthService _authService;

  @override
  late final String _clientId;

  @override
  late final String _clientSecret;

  @override
  late final AnalyticsService _analyticsService;

  @override
  late final AnalyticsFacade _analyticsFacade;

  @override
  late final Talker _talker;

  @override
  late final AppLoggerFacade _appLogger;

  @override
  late final AuthErrorHandler _errorHandler;
}

void main() {
  late TrackedAnalyticsService trackedAnalyticsService;
  late TrackedAuthNotifier trackedAuthNotifier;
  late MockAuthService mockAuthService;
  late MockAnalyticsFacade mockAnalyticsFacade;
  late MockTalker mockTalker;
  late MockAppLoggerFacade mockAppLoggerFacade;
  late MockAuthErrorHandler mockAuthErrorHandler;

  setUp(() {
    trackedAnalyticsService = TrackedAnalyticsService();
    mockAuthService = MockAuthService();
    mockAnalyticsFacade = MockAnalyticsFacade();
    mockTalker = MockTalker();
    mockAppLoggerFacade = MockAppLoggerFacade();
    mockAuthErrorHandler = MockAuthErrorHandler();
    trackedAuthNotifier = TrackedAuthNotifier();

    // Setup auth service mocks
    when(() => mockAuthService.isLoggedIn()).thenAnswer((_) async => false);

    // Setup analytics facade mocks
    when(() => mockAnalyticsFacade.trackLogin()).thenAnswer((_) async {});
    when(
      () => mockAnalyticsFacade.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});
    when(() => mockAnalyticsFacade.logScreenView(any(), any())).thenAnswer((_) async {});

    // Setup error handler mocks
    when(
      () => mockAuthErrorHandler.processError(
        any(),
        any(),
        context: any(named: 'context'),
        additionalData: any(named: 'additionalData'),
      ),
    ).thenAnswer((_) async => 'Error message');

    // Setup logger mocks
    when(() => mockAppLoggerFacade.i(any())).thenReturn(null);
    when(() => mockAppLoggerFacade.error(any(), any(), any(), any(), any())).thenReturn(null);
  });

  Widget buildLoginPage() {
    return ProviderScope(
      overrides: [
        analyticsServiceProvider.overrideWithValue(trackedAnalyticsService),
        analyticsFacadeProvider.overrideWithValue(mockAnalyticsFacade),
        authServiceProvider.overrideWithValue(mockAuthService),
        talkerProvider.overrideWithValue(mockTalker),
        appLoggerFacadeProvider.overrideWithValue(mockAppLoggerFacade),
        authErrorHandlerProvider.overrideWithValue(mockAuthErrorHandler),
        // We need a different override approach for state notifier providers
        authStateProvider.overrideWith((_) => trackedAuthNotifier),
      ],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('should display login form elements correctly', (tester) async {
      await tester.pumpWidget(buildLoginPage());

      // Verify all key elements are displayed
      expect(find.text('Memverse Login'), findsOneWidget);
      expect(find.text('Welcome to Memverse'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.byKey(loginUsernameFieldKey), findsOneWidget);
      expect(find.byKey(loginPasswordFieldKey), findsOneWidget);
      expect(find.byKey(loginButtonKey), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should validate empty username field', (tester) async {
      await tester.pumpWidget(buildLoginPage());

      // Leave username empty
      await tester.enterText(find.byKey(loginPasswordFieldKey), 'password123');
      await tester.tap(find.byKey(loginButtonKey));
      await tester.pump();

      // Check error is displayed and analytics is tracked
      expect(find.text('Please enter your username or email'), findsOneWidget);
      expect(trackedAnalyticsService.trackEmptyUsernameValidationCalls, 1);
      expect(trackedAuthNotifier.loginCalls.isEmpty, true);
    });

    testWidgets('should validate too short username', (tester) async {
      await tester.pumpWidget(buildLoginPage());

      // Enter too short username (less than 3 chars)
      await tester.enterText(find.byKey(loginUsernameFieldKey), 'ab');
      await tester.enterText(find.byKey(loginPasswordFieldKey), 'password123');
      await tester.tap(find.byKey(loginButtonKey));
      await tester.pump();

      // Check error is displayed and analytics is tracked
      expect(find.text('Username must be at least 3 characters'), findsOneWidget);
      expect(trackedAnalyticsService.trackInvalidUsernameValidationCalls, 1);
      expect(trackedAuthNotifier.loginCalls.isEmpty, true);
    });

    testWidgets('should validate empty password field', (tester) async {
      await tester.pumpWidget(buildLoginPage());

      // Leave password empty
      await tester.enterText(find.byKey(loginUsernameFieldKey), 'validuser');
      await tester.tap(find.byKey(loginButtonKey));
      await tester.pump();

      // Check error is displayed and analytics is tracked
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(trackedAnalyticsService.trackEmptyPasswordValidationCalls, 1);
      expect(trackedAuthNotifier.loginCalls.isEmpty, true);
    });

    testWidgets('should validate too short password', (tester) async {
      await tester.pumpWidget(buildLoginPage());

      // Enter too short password (less than 8 chars)
      await tester.enterText(find.byKey(loginUsernameFieldKey), 'validuser');
      await tester.enterText(find.byKey(loginPasswordFieldKey), 'short');
      await tester.tap(find.byKey(loginButtonKey));
      await tester.pump();

      // Check error is displayed and analytics is tracked
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
      expect(trackedAnalyticsService.trackInvalidPasswordValidationCalls, 1);
      expect(trackedAuthNotifier.loginCalls.isEmpty, true);
    });

    testWidgets('should trim whitespace from credentials before login', (tester) async {
      await tester.pumpWidget(buildLoginPage());

      // Enter valid credentials with extra whitespace
      await tester.enterText(find.byKey(loginUsernameFieldKey), '  validuser  ');
      await tester.enterText(find.byKey(loginPasswordFieldKey), '  password123  ');
      await tester.tap(find.byKey(loginButtonKey));
      await tester.pump();

      // Verify login was called with trimmed credentials
      expect(trackedAuthNotifier.loginCalls.length, 1);
      expect(trackedAuthNotifier.loginCalls.first['username'], 'validuser');
      expect(trackedAuthNotifier.loginCalls.first['password'], 'password123');
    });

    testWidgets('should accept valid email address as username', (tester) async {
      await tester.pumpWidget(buildLoginPage());

      // Enter valid email and password
      await tester.enterText(find.byKey(loginUsernameFieldKey), 'user@example.com');
      await tester.enterText(find.byKey(loginPasswordFieldKey), 'password123');
      await tester.tap(find.byKey(loginButtonKey));
      await tester.pump();

      // Verify login was called with correct credentials
      expect(trackedAuthNotifier.loginCalls.length, 1);
      expect(trackedAuthNotifier.loginCalls.first['username'], 'user@example.com');
      expect(trackedAuthNotifier.loginCalls.first['password'], 'password123');
    });

    testWidgets('should validate invalid email format', (tester) async {
      await tester.pumpWidget(buildLoginPage());

      // Enter invalid email format
      await tester.enterText(find.byKey(loginUsernameFieldKey), 'invalid@email');
      await tester.enterText(find.byKey(loginPasswordFieldKey), 'password123');
      await tester.tap(find.byKey(loginButtonKey));
      await tester.pump();

      // Check error is displayed and analytics is tracked
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(trackedAnalyticsService.trackInvalidUsernameValidationCalls, 1);
      expect(trackedAuthNotifier.loginCalls.isEmpty, true);
    });

    testWidgets('should show loading indicator when login button is pressed with valid input', (
      tester,
    ) async {
      // Set up loading state
      trackedAuthNotifier.state = AuthState(isLoading: true);

      await tester.pumpWidget(buildLoginPage());

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when auth state has error', (tester) async {
      // Set up error state
      trackedAuthNotifier.state = AuthState(error: 'Invalid credentials');

      await tester.pumpWidget(buildLoginPage());

      // Error message should be displayed
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
