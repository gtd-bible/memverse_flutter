// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_mocked_app_is_running_in_demo_mode.dart';
import './step/i_see_scripture_app_demo.dart';
import './step/i_see_the_add_button.dart';
import './step/i_tap_the_add_button.dart';
import './step/i_enter_john316_in_the_form.dart';
import './step/i_tap_submit.dart';
import './step/i_see_a_success_message.dart';
import './step/the_mocked_app_is_running_in_demo_mode_with_verses.dart';
import './step/i_see_john316.dart';
import './step/i_tap_john316.dart';
import './step/i_see_the_verse_dialog.dart';
import './step/i_swipe_left_on_john316.dart';
import './step/i_tap_delete.dart';
import './step/i_no_longer_see_john316.dart';
import './step/i_tap_submit_without_entering_anything.dart';
import './step/i_see_please_enter_some_text.dart';

void main() {
  group('''Demo Mode Basic Flows''', () {
    testWidgets('''Open demo mode and see the app''', (tester) async {
      await theMockedAppIsRunningInDemoMode(tester);
      await iSeeScriptureAppDemo(tester);
      await iSeeTheAddButton(tester);
    });
    testWidgets('''Add a verse to my list''', (tester) async {
      await theMockedAppIsRunningInDemoMode(tester);
      await iTapTheAddButton(tester);
      await iEnterJohn316InTheForm(tester);
      await iTapSubmit(tester);
      await iSeeASuccessMessage(tester);
    });
    testWidgets('''View my verses''', (tester) async {
      await theMockedAppIsRunningInDemoModeWithVerses(tester);
      await iSeeJohn316(tester);
      await iTapJohn316(tester);
      await iSeeTheVerseDialog(tester);
    });
    testWidgets('''Delete a verse''', (tester) async {
      await theMockedAppIsRunningInDemoModeWithVerses(tester);
      await iSwipeLeftOnJohn316(tester);
      await iTapDelete(tester);
      await iNoLongerSeeJohn316(tester);
    });
    testWidgets('''Form validation works''', (tester) async {
      await theMockedAppIsRunningInDemoMode(tester);
      await iTapTheAddButton(tester);
      await iTapSubmitWithoutEnteringAnything(tester);
      await iSeePleaseEnterSomeText(tester);
    });
  });
}
