// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@Tags(['authentication @widget'])
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_enter_a_valid_password_into_the_loginpasswordfield_text_field.dart';
import './step/i_enter_a_valid_username_into_the_loginusernamefield_text_field.dart';
import './step/i_enter_wrongpassword_into_the_loginpasswordfield_text_field.dart';
import './step/i_see_the_dashboard_text.dart';
import './step/i_see_the_invalid_username_or_password_text.dart';
import './step/i_tap_the_loginbutton_button.dart';
import './step/the_app_is_runningxt.dart';

void main() {
  group('''User Authentication''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsRunning(tester);
    }

    testWidgets('''Successful login''', (tester) async {
      await bddSetUp(tester);
      await iEnterAValidUsernameIntoTheLoginusernamefieldTextField(tester);
      await iEnterAValidPasswordIntoTheLoginpasswordfieldTextField(tester);
      await iTapTheLoginbuttonButton(tester);
      await iSeeTheDashboardText(tester);
    });
    testWidgets('''Failed login with wrong password''', (tester) async {
      await bddSetUp(tester);
      await iEnterAValidUsernameIntoTheLoginusernamefieldTextField(tester);
      await iEnterWrongpasswordIntoTheLoginpasswordfieldTextField(tester);
      await iTapTheLoginbuttonButton(tester);
      await iSeeTheInvalidUsernameOrPasswordText(tester);
    });
  });
}
