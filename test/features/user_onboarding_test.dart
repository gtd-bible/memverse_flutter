// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_open_the_app_for_the_first_time.dart';
import './step/i_see_the_login_screen.dart';
import './step/i_see_login_heading.dart';
import './step/i_see_username_and_password_fields.dart';
import './step/i_see_continue_as_guest_option.dart';
import './step/i_tap_continue_as_guest.dart';
import './step/i_am_taken_to_the_home_screen.dart';
import './step/i_can_start_using_the_app_immediately.dart';
import './step/i_previously_logged_in_successfully.dart';
import './step/i_open_the_app.dart';
import './step/i_am_automatically_logged_in.dart';
import './step/i_see_the_home_screen.dart';
import './step/i_enter_my_username_and_password.dart';
import './step/i_tap_login.dart';
import './step/i_am_authenticated.dart';
import './step/i_see_my_personalized_home_screen.dart';

void main() {
  group('''User Onboarding and First Experience''', () {
    testWidgets('''First time user sees welcome and can login''',
        (tester) async {
      await iOpenTheAppForTheFirstTime(tester);
      await iSeeTheLoginScreen(tester);
      await iSeeLoginHeading(tester);
      await iSeeUsernameAndPasswordFields(tester);
      await iSeeContinueAsGuestOption(tester);
    });
    testWidgets('''Quick start with guest mode''', (tester) async {
      await iOpenTheAppForTheFirstTime(tester);
      await iTapContinueAsGuest(tester);
      await iAmTakenToTheHomeScreen(tester);
      await iCanStartUsingTheAppImmediately(tester);
    });
    testWidgets('''Returning user is remembered''', (tester) async {
      await iPreviouslyLoggedInSuccessfully(tester);
      await iOpenTheApp(tester);
      await iAmAutomaticallyLoggedIn(tester);
      await iSeeTheHomeScreen(tester);
    });
    testWidgets('''User logs in with valid credentials''', (tester) async {
      await iOpenTheApp(tester);
      await iEnterMyUsernameAndPassword(tester);
      await iTapLogin(tester);
      await iAmAuthenticated(tester);
      await iSeeMyPersonalizedHomeScreen(tester);
    });
  });
}
