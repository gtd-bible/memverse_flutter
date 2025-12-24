// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_open_demo_mode_for_the_first_time.dart';
import './step/i_see3_starter_verses_already_loaded.dart';
import './step/i_see_scripture_app_demo_in_the_header.dart';
import './step/i_can_immediately_start_practicing.dart';
import './step/i_am_in_demo_mode.dart';
import './step/i_tap_the_add_button.dart';
import './step/i_type_psalm231.dart';
import './step/i_tap_submit.dart';
import './step/psalm231_appears_in_my_list.dart';
import './step/i_can_tap_it_to_view_the_full_text.dart';
import './step/i_add_john316_romans828_philippians413.dart';
import './step/all3_verses_appear_in_my_list.dart';
import './step/each_verse_is_separately_viewable.dart';
import './step/i_am_adding_a_verse.dart';
import './step/i_forget_to_fill_in_the_reference.dart';
import './step/i_see_a_helpful_validation_message.dart';
import './step/i_can_fix_my_mistake.dart';

void main() {
  group('''Demo Mode - Try Before You Sign Up''', () {
    testWidgets('''First time using demo mode''', (tester) async {
      await iOpenDemoModeForTheFirstTime(tester);
      await iSee3StarterVersesAlreadyLoaded(tester);
      await iSeeScriptureAppDemoInTheHeader(tester);
      await iCanImmediatelyStartPracticing(tester);
    });
    testWidgets('''Add my first custom verse''', (tester) async {
      await iAmInDemoMode(tester);
      await iTapTheAddButton(tester);
      await iTypePsalm231(tester);
      await iTapSubmit(tester);
      await psalm231AppearsInMyList(tester);
      await iCanTapItToViewTheFullText(tester);
    });
    testWidgets('''Quick add multiple verses''', (tester) async {
      await iAmInDemoMode(tester);
      await iAddJohn316Romans828Philippians413(tester);
      await all3VersesAppearInMyList(tester);
      await eachVerseIsSeparatelyViewable(tester);
    });
    testWidgets('''Form validation helps me''', (tester) async {
      await iAmAddingAVerse(tester);
      await iForgetToFillInTheReference(tester);
      await iTapSubmit(tester);
      await iSeeAHelpfulValidationMessage(tester);
      await iCanFixMyMistake(tester);
    });
  });
}
