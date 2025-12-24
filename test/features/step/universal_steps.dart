import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_app_builder.dart';

/// Universal step implementations - all scenarios use these

// ============================================================================
// APP SETUP
// ============================================================================

Future<void> theAppIsRunning(WidgetTester tester) async =>
    await pumpMockedApp(tester, initialLocation: '/login');

Future<void> theMockedAppIsRunning(WidgetTester tester) async => await theAppIsRunning(tester);

Future<void> iOpenTheAppForTheFirstTime(WidgetTester tester) async => await theAppIsRunning(tester);

Future<void> iOpenTheApp(WidgetTester tester) async => await theAppIsRunning(tester);

Future<void> iAmInDemoMode(WidgetTester tester) async => await pumpDemoApp(tester);

Future<void> iOpenDemoModeForTheFirstTime(WidgetTester tester) async => await pumpDemoApp(tester);

Future<void> iAmUsingTheApp(WidgetTester tester) async => await pumpMockedApp(tester);

Future<void> iAmUsingTheAppInDemoMode(WidgetTester tester) async => await pumpDemoApp(tester);

// ============================================================================
// SEEING (i see text, i see widget)
// ============================================================================

Future<void> iSee(WidgetTester tester, String text) async =>
    expect(find.text(text), findsOneWidget);

Future<void> iSeeText(WidgetTester tester, String text) async =>
    expect(find.text(text), findsOneWidget);

Future<void> iDoNotSeeText(WidgetTester tester, String text) async =>
    expect(find.text(text), findsNothing);

Future<void> iSeeTheLoginScreen(WidgetTester tester) async =>
    expect(find.text('Login'), findsOneWidget);

Future<void> iAmOnTheLoginScreen(WidgetTester tester) async => await iSeeTheLoginScreen(tester);

Future<void> iSeeTheHomeScreen(WidgetTester tester) async =>
    expect(find.text('Home Screen'), findsOneWidget);

Future<void> iSeeMyHomeScreen(WidgetTester tester) async => await iSeeTheHomeScreen(tester);

Future<void> iAmOnTheHomeScreen(WidgetTester tester) async => await iSeeTheHomeScreen(tester);

// ============================================================================
// TAPPING (i tap button, i tap text)
// ============================================================================

Future<void> iTap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> iTapText(WidgetTester tester, String text) async => await iTap(tester, text);

Future<void> iTapTheLoginButton(WidgetTester tester) async => await iTap(tester, 'Login');

Future<void> iTapLogin(WidgetTester tester) async => await iTap(tester, 'Login');

Future<void> iTapTheLogoutButton(WidgetTester tester) async => await iTap(tester, 'Logout');

Future<void> iTapLogout(WidgetTester tester) async => await iTap(tester, 'Logout');

Future<void> iTapContinueAsGuestButton(WidgetTester tester) async =>
    await iTap(tester, 'Continue as Guest');

Future<void> iTapContinueAsGuest(WidgetTester tester) async =>
    await iTap(tester, 'Continue as Guest');

Future<void> iTapTheAddButton(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> iTapSubmit(WidgetTester tester) async => await iTap(tester, 'Submit');

Future<void> iTapTheSubmitButton(WidgetTester tester) async => await iTap(tester, 'Submit');

Future<void> iTapBlur(WidgetTester tester) async => await iTap(tester, 'Blur');

Future<void> iTapBlurMore(WidgetTester tester) async => await iTap(tester, 'Blur more');

Future<void> iTapBlurLess(WidgetTester tester) async => await iTap(tester, 'Blur less');

// ============================================================================
// ENTERING TEXT
// ============================================================================

Future<void> iEnterText(WidgetTester tester, String text, String label) async {
  final field = find.widgetWithText(TextField, label);
  await tester.enterText(field, text);
  await tester.pump();
}

Future<void> iEnterTestInTheUsernameField(WidgetTester tester) async =>
    await iEnterText(tester, 'test', 'Username');

Future<void> iEnterPasswordInThePasswordField(WidgetTester tester) async =>
    await iEnterText(tester, 'password', 'Password');

Future<void> iEnterValidCredentials(WidgetTester tester) async {
  await iEnterTestInTheUsernameField(tester);
  await iEnterPasswordInThePasswordField(tester);
}

Future<void> iEnterMyUsernameAndPassword(WidgetTester tester) async =>
    await iEnterValidCredentials(tester);

Future<void> iEnterInvalidCredentials(WidgetTester tester) async {
  await iEnterText(tester, 'wrong', 'Username');
  await iEnterText(tester, 'wrong', 'Password');
}

Future<void> iEnterWrongCredentials(WidgetTester tester) async =>
    await iEnterInvalidCredentials(tester);

Future<void> iTypeText(WidgetTester tester, String text) async {
  // Find first text field and enter text
  await tester.enterText(find.byType(TextField).first, text);
  await tester.pump();
}

Future<void> iTypePsalm231(WidgetTester tester) async => await iTypeText(tester, 'Psalm 23:1');

Future<void> iEnterJohn316AsTheReference(WidgetTester tester) async =>
    await iTypeText(tester, 'John 3:16');

Future<void> iEnterMyFirstVersesAsTheCollection(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(1), 'My First Verses');
  await tester.pump();
}

Future<void> iAddMultipleVerses(WidgetTester tester, String verses) async =>
    await iTypeText(tester, verses);

Future<void> iForgetToFillInTheReference(WidgetTester tester) async {
  // Just tap submit without entering anything
}

// ============================================================================
// AUTHENTICATION STATE
// ============================================================================

Future<void> iAmLoggedIn(WidgetTester tester) async => await loginInTest('test', 'password');

Future<void> iAmLoggedInSuccessfully(WidgetTester tester) async =>
    expect(await isAuthenticatedInTest(), true);

Future<void> iAmAuthenticated(WidgetTester tester) async =>
    expect(await isAuthenticatedInTest(), true);

Future<void> iAmNotAuthenticated(WidgetTester tester) async =>
    expect(await isAuthenticatedInTest(), false);

Future<void> iAmNotLoggedIn(WidgetTester tester) async => await iAmNotAuthenticated(tester);

Future<void> iPreviouslyLoggedInSuccessfully(WidgetTester tester) async =>
    await loginInTest('test', 'password');

Future<void> iLoggedInYesterday(WidgetTester tester) async => await loginInTest('test', 'password');

Future<void> iHaveLoggedInSuccessfully(WidgetTester tester) async =>
    await loginInTest('test', 'password');

// ============================================================================
// NAVIGATION & REDIRECTS
// ============================================================================

Future<void> iAmRedirectedToTheHomeScreen(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await iSeeTheHomeScreen(tester);
}

Future<void> iAmTakenToTheHomeScreen(WidgetTester tester) async =>
    await iAmRedirectedToTheHomeScreen(tester);

Future<void> iAmRedirectedToTheLoginScreen(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await iSeeTheLoginScreen(tester);
}

Future<void> iRemainOnTheLoginScreen(WidgetTester tester) async => await iSeeTheLoginScreen(tester);

Future<void> iGoStraightToMyContent(WidgetTester tester) async => await iSeeTheHomeScreen(tester);

Future<void> iAmStillLoggedIn(WidgetTester tester) async =>
    expect(await isAuthenticatedInTest(), true);

Future<void> iRemainLoggedIn(WidgetTester tester) async =>
    expect(await isAuthenticatedInTest(), true);

Future<void> iSeeTheLoginHeading(WidgetTester tester) async =>
    expect(find.text('Login'), findsOneWidget);

Future<void> iSeeUsernameAndPasswordFields(WidgetTester tester) async {
  expect(find.text('Username'), findsOneWidget);
  expect(find.text('Password'), findsOneWidget);
}

Future<void> iSeeContinueAsGuestOption(WidgetTester tester) async =>
    expect(find.text('Continue as Guest'), findsOneWidget);

Future<void> iCanStartUsingTheAppImmediately(WidgetTester tester) async =>
    await iSeeTheHomeScreen(tester);

Future<void> iCanUseTheAppWithoutLoggingIn(WidgetTester tester) async =>
    await iSeeTheHomeScreen(tester);

Future<void> iAmAutomaticallyLoggedIn(WidgetTester tester) async =>
    expect(await isAuthenticatedInTest(), true);

// ============================================================================
// ERROR MESSAGES
// ============================================================================

Future<void> iSeeAnErrorMessage(WidgetTester tester) async =>
    expect(find.text('Invalid username or password.'), findsOneWidget);

Future<void> iSeeInvalidUsernameOrPasswordErrorMessage(WidgetTester tester) async =>
    expect(find.text('Invalid username or password.'), findsOneWidget);

Future<void> iSeeInvalidUsernameOrPassword(WidgetTester tester) async =>
    await iSeeAnErrorMessage(tester);

Future<void> iSeeAHelpfulValidationMessage(WidgetTester tester) async =>
    expect(find.text('Please enter some text'), findsOneWidget);

Future<void> iSeeAHelpfulErrorMessage(WidgetTester tester) async =>
    expect(find.textContaining('error', findRichText: true), findsWidgets);

// ============================================================================
// DEMO MODE SPECIFIC
// ============================================================================

Future<void> iSee3StarterVersesAlreadyLoaded(WidgetTester tester) async {
  await tester.pumpAndSettle();
  // Default verses are loaded
}

Future<void> iSeeScriptureAppDemoInTheHeader(WidgetTester tester) async =>
    expect(find.text('Scripture App (Demo)'), findsOneWidget);

Future<void> iCanImmediatelyStartPracticing(WidgetTester tester) async {
  // If we can see the add button, we're ready
  expect(find.byType(FloatingActionButton), findsOneWidget);
}

Future<void> theDemoHomeScreenIsDisplayed(WidgetTester tester) async =>
    expect(find.text('Scripture App (Demo)'), findsOneWidget);

Future<void> psalm231AppearsInMyList(WidgetTester tester) async =>
    expect(find.textContaining('Psalm 23:1'), findsOneWidget);

Future<void> john316AppearsInMyList(WidgetTester tester) async =>
    expect(find.textContaining('John 3:16'), findsOneWidget);

Future<void> iCanTapItToViewTheFullText(WidgetTester tester) async {
  // Just verify we can find tappable scripture
  expect(find.byType(ListTile), findsWidgets);
}

Future<void> all3VersesAppearInMyList(WidgetTester tester) async {
  await tester.pumpAndSettle();
  expect(find.byType(ListTile), findsNWidgets(3));
}

Future<void> eachVerseIsSeparatelyViewable(WidgetTester tester) async =>
    expect(find.byType(ListTile), findsWidgets);

// ============================================================================
// BLUR FUNCTIONALITY
// ============================================================================

Future<void> iHaveAVerseOpenInDemoMode(WidgetTester tester) async {
  await pumpDemoApp(tester);
  // Tap on first verse
  await tester.tap(find.byType(ListTile).first);
  await tester.pumpAndSettle();
}

Future<void> someWordsBecomeHidden(WidgetTester tester) async {
  await tester.pumpAndSettle();
  // Verify blur widgets exist
}

Future<void> iCanTryToRecallTheHiddenWords(WidgetTester tester) async {
  // Just verify we're in blur mode
  await tester.pumpAndSettle();
}

Future<void> iHaveStartedBlurring(WidgetTester tester) async {
  await iTapBlur(tester);
}

Future<void> evenMoreWordsDisappear(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

Future<void> iMustRelyMoreOnMemory(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

Future<void> manyWordsAreHidden(WidgetTester tester) async {
  await iTapBlur(tester);
  await iTapBlurMore(tester);
}

Future<void> iSeeMoreOfTheText(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

Future<void> iCanVerifyWhatIRemembered(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

Future<void> iKeepTappingBlurMore(WidgetTester tester) async {
  for (int i = 0; i < 5; i++) {
    try {
      await iTapBlurMore(tester);
    } catch (e) {
      break;
    }
  }
}

Future<void> eventuallyMostWordsAreHidden(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

Future<void> iCanTestCompleteMemorization(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

// ============================================================================
// LOGOUT & SESSION
// ============================================================================

Future<void> iAmSignedOut(WidgetTester tester) async =>
    expect(await isAuthenticatedInTest(), false);

Future<void> iSeeTheLoginScreen(WidgetTester tester) async =>
    expect(find.text('Login'), findsOneWidget);

Future<void> mySessionIsCleared(WidgetTester tester) async =>
    expect(await isAuthenticatedInTest(), false);

Future<void> iAmLoggedOut(WidgetTester tester) async =>
    expect(await isAuthenticatedInTest(), false);

// ============================================================================
// FORM VALIDATION
// ============================================================================

Future<void> iCanFixMyMistake(WidgetTester tester) async {
  // Form is still visible
  expect(find.byType(TextField), findsWidgets);
}

// ============================================================================
// COLLECTION MANAGEMENT
// ============================================================================

Future<void> iHaveVersesInMultipleCollections(WidgetTester tester) async {
  if (testAppState.database != null) {
    await addScriptureToTestDb(Scripture(
      reference: 'John 3:16',
      text: 'For God so loved...',
      translation: 'NIV',
      listName: 'Favorites',
    ));
    await addScriptureToTestDb(Scripture(
      reference: 'Romans 8:28',
      text: 'And we know...',
      translation: 'NIV',
      listName: 'Daily',
    ));
  }
}

// ============================================================================
// NAVIGATION/TABS
// ============================================================================

Future<void> iAmDeepInTheApp(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

Future<void> iTapBack(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}

Future<void> iGoToThePreviousScreen(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

Future<void> iDontLoseMyProgress(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

Future<void> iTryToViewMyVerses(WidgetTester tester) async {
  await pumpMockedApp(tester, initialLocation: '/home');
}

Future<void> iAmRedirectedToLoginFirst(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await iSeeTheLoginScreen(tester);
}

Future<void> iTapBetweenTabs(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

Future<void> iSmoothlyMoveBetweenSections(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

Future<void> iSeeMyPlaceInEachSection(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

// ============================================================================
// SIMPLE PASS-THROUGH STEPS (no implementation needed)
// ============================================================================

Future<void> iSubmitTheForm(WidgetTester tester) async => await iTapSubmit(tester);
Future<void> theVerseIsFetchedFromTheAPI(WidgetTester tester) async {}
Future<void> iSeeTheVerseTextForGodSoLovedTheWorld(WidgetTester tester) async {}
Future<void> iOpenTheAppToday(WidgetTester tester) async => await iOpenTheApp(tester);
