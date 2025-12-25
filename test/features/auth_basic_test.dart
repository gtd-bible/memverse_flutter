// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_mocked_app_is_running_at_login.dart';
import './step/i_enter_test_in_username.dart';
import './step/i_enter_password_in_password.dart';
import './step/i_tap_login.dart';
import './step/i_see_home_screen.dart';
import './step/i_enter_wrong_in_username.dart';
import './step/i_enter_wrong_in_password.dart';
import './step/i_see_invalid_username_or_password.dart';
import './step/i_tap_continue_as_guest.dart';

void main() {
  group('''Authentication Basic Flows''', () {
    testWidgets('''Login with valid credentials''', (tester) async {
      await theMockedAppIsRunningAtLogin(tester);
      await iEnterTestInUsername(tester);
      await iEnterPasswordInPassword(tester);
      await iTapLogin(tester);
      await iSeeHomeScreen(tester);
    });
    testWidgets('''Login with invalid credentials''', (tester) async {
      await theMockedAppIsRunningAtLogin(tester);
      await iEnterWrongInUsername(tester);
      await iEnterWrongInPassword(tester);
      await iTapLogin(tester);
      await iSeeInvalidUsernameOrPassword(tester);
    });
    testWidgets('''Guest mode access''', (tester) async {
      await theMockedAppIsRunningAtLogin(tester);
      await iTapContinueAsGuest(tester);
      await iSeeHomeScreen(tester);
    });
  });
}
