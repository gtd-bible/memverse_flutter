// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_starts.dart';
import './step/i_enter_test_in_the_username_field.dart';
import './step/i_enter_password_in_the_password_field.dart';
import './step/i_tap_login.dart';
import './step/i_see_home.dart';

void main() {
  group('''Login''', () {
    testWidgets('''Successful login''', (tester) async {
      await theAppStarts(tester);
      await iEnterTestInTheUsernameField(tester);
      await iEnterPasswordInThePasswordField(tester);
      await iTapLogin(tester);
      await iSeeHome(tester);
    });
  });
}
