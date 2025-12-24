// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';
import './step/i_enter_valid_credentials.dart';
import './step/i_tap_login.dart';
import './step/i_am_logged_in.dart';
import './step/i_see_my_home_screen.dart';
import './step/i_enter_invalid_credentials.dart';
import './step/i_see_an_error_message.dart';
import './step/i_remain_on_the_login_screen.dart';
import './step/i_tap_continue_as_guest.dart';
import './step/i_can_use_the_app_without_logging_in.dart';
import './step/i_logged_in_yesterday.dart';
import './step/i_open_the_app_today.dart';
import './step/i_am_still_logged_in.dart';
import './step/i_go_straight_to_my_content.dart';
import './step/i_tap_logout.dart';
import './step/i_am_signed_out.dart';
import './step/i_see_the_login_screen.dart';
import './step/my_session_is_cleared.dart';

void main() {
  group('''User Authentication''', () {
    testWidgets('''Successful login flow''', (tester) async {
      await theAppIsRunning(tester);
      await iEnterValidCredentials(tester);
      await iTapLogin(tester);
      await iAmLoggedIn(tester);
      await iSeeMyHomeScreen(tester);
    });
    testWidgets('''Invalid credentials are rejected''', (tester) async {
      await theAppIsRunning(tester);
      await iEnterInvalidCredentials(tester);
      await iTapLogin(tester);
      await iSeeAnErrorMessage(tester);
      await iRemainOnTheLoginScreen(tester);
    });
    testWidgets('''Guest mode for quick access''', (tester) async {
      await theAppIsRunning(tester);
      await iTapContinueAsGuest(tester);
      await iCanUseTheAppWithoutLoggingIn(tester);
    });
    testWidgets('''Stay logged in across sessions''', (tester) async {
      await iLoggedInYesterday(tester);
      await iOpenTheAppToday(tester);
      await iAmStillLoggedIn(tester);
      await iGoStraightToMyContent(tester);
    });
    testWidgets('''Logout and security''', (tester) async {
      await iAmLoggedIn(tester);
      await iTapLogout(tester);
      await iAmSignedOut(tester);
      await iSeeTheLoginScreen(tester);
      await mySessionIsCleared(tester);
    });
  });
}
