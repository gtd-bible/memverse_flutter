// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';
import './step/i_see_the_login_screen.dart';
import './step/i_tap_continue_as_guest.dart';
import './step/i_see_the_home_screen.dart';

void main() {
  group('''Guest Mode''', () {
    testWidgets('''User continues as guest''', (tester) async {
      await theAppIsRunning(tester);
      await iSeeTheLoginScreen(tester);
      await iTapContinueAsGuest(tester);
      await iSeeTheHomeScreen(tester);
    });
  });
}
