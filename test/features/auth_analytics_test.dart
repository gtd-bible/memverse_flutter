// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_installed_and_launched.dart';
import './step/analytics_collection_is_enabled.dart';
import './step/crashlytics_reporting_is_enabled.dart';
import './step/the_user_enters_a_valid_username_and_password.dart';
import './step/taps_the_login_button.dart';
import './step/a_login_attempt_event_should_be_logged_with_username_length_parameter.dart';
import './step/a_login_standard_firebase_event_should_be_logged.dart';
import './step/a_login_success_event_should_be_logged_with_user_id_token_type_and_authenticated_parameters.dart';
import './step/the_user_should_be_navigated_to_the_dashboard_screen.dart';
import './step/the_user_id_should_be_set_in_both_analytics_and_crashlytics.dart';
import './step/the_user_enters_an_invalid_username_and_password.dart';
import './step/an_auth_error_event_should_be_logged_with_error_details.dart';
import './step/the_error_should_be_recorded_in_crashlytics_with_stack_trace.dart';
import './step/a_nonfatal_error_should_be_logged_with_additional_data.dart';
import './step/an_appropriate_error_message_should_be_displayed_to_the_user.dart';
import './step/the_server_returns_an_empty_token_response.dart';
import './step/a_login_empty_token_event_should_be_logged.dart';
import './step/the_error_should_be_recorded_in_talker.dart';
import './step/a_network_error_occurs_during_login.dart';
import './step/a_nonfatal_error_should_be_recorded_with_reason_login_failure.dart';
import './step/relevant_diagnostic_information_should_be_attached_to_the_error.dart';
import './step/the_user_is_logged_in.dart';
import './step/the_user_logs_out.dart';
import './step/a_user_logout_event_should_be_logged_with_user_id_and_session_active_parameters.dart';
import './step/a_logout_event_should_be_logged.dart';
import './step/the_user_should_be_navigated_to_the_login_screen.dart';
import './step/an_error_occurs_during_logout.dart';
import './step/a_nonfatal_error_should_be_recorded_with_reason_logout_failure.dart';

void main() {
  group('''Authentication Analytics & Crashlytics''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsInstalledAndLaunched(tester);
      await analyticsCollectionIsEnabled(tester);
      await crashlyticsReportingIsEnabled(tester);
    }

    testWidgets('''Successful login with valid credentials''', (tester) async {
      await bddSetUp(tester);
      await theUserEntersAValidUsernameAndPassword(tester);
      await tapsTheLoginButton(tester);
      await aLoginAttemptEventShouldBeLoggedWithUsernameLengthParameter(tester);
      await aLoginStandardFirebaseEventShouldBeLogged(tester);
      await aLoginSuccessEventShouldBeLoggedWithUserIdTokenTypeAndAuthenticatedParameters(
          tester);
      await theUserShouldBeNavigatedToTheDashboardScreen(tester);
      await theUserIdShouldBeSetInBothAnalyticsAndCrashlytics(tester);
    });
    testWidgets('''Failed login with invalid credentials''', (tester) async {
      await bddSetUp(tester);
      await theUserEntersAnInvalidUsernameAndPassword(tester);
      await tapsTheLoginButton(tester);
      await aLoginAttemptEventShouldBeLoggedWithUsernameLengthParameter(tester);
      await anAuthErrorEventShouldBeLoggedWithErrorDetails(tester);
      await theErrorShouldBeRecordedInCrashlyticsWithStackTrace(tester);
      await aNonfatalErrorShouldBeLoggedWithAdditionalData(tester);
      await anAppropriateErrorMessageShouldBeDisplayedToTheUser(tester);
    });
    testWidgets('''Failed login with empty token response''', (tester) async {
      await bddSetUp(tester);
      await theServerReturnsAnEmptyTokenResponse(tester);
      await aLoginEmptyTokenEventShouldBeLogged(tester);
      await theErrorShouldBeRecordedInTalker(tester);
      await anAppropriateErrorMessageShouldBeDisplayedToTheUser(tester);
    });
    testWidgets('''Network error during login''', (tester) async {
      await bddSetUp(tester);
      await aNetworkErrorOccursDuringLogin(tester);
      await theErrorShouldBeRecordedInCrashlyticsWithStackTrace(tester);
      await anAuthErrorEventShouldBeLoggedWithErrorDetails(tester);
      await aNonfatalErrorShouldBeRecordedWithReasonLoginFailure(tester);
      await relevantDiagnosticInformationShouldBeAttachedToTheError(tester);
      await anAppropriateErrorMessageShouldBeDisplayedToTheUser(tester);
    });
    testWidgets('''Successful logout''', (tester) async {
      await bddSetUp(tester);
      await theUserIsLoggedIn(tester);
      await theUserLogsOut(tester);
      await aUserLogoutEventShouldBeLoggedWithUserIdAndSessionActiveParameters(
          tester);
      await aLogoutEventShouldBeLogged(tester);
      await theUserShouldBeNavigatedToTheLoginScreen(tester);
    });
    testWidgets('''Error during logout''', (tester) async {
      await bddSetUp(tester);
      await theUserIsLoggedIn(tester);
      await anErrorOccursDuringLogout(tester);
      await theErrorShouldBeRecordedInCrashlyticsWithStackTrace(tester);
      await anAuthErrorEventShouldBeLoggedWithErrorDetails(tester);
      await aNonfatalErrorShouldBeRecordedWithReasonLogoutFailure(tester);
      await anAppropriateErrorMessageShouldBeDisplayedToTheUser(tester);
    });
  });
}
