// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_am_not_logged_in.dart';
import './step/i_try_to_view_my_verses.dart';
import './step/i_am_redirected_to_login_first.dart';
import './step/i_am_logged_in.dart';
import './step/i_tap_between_tabs.dart';
import './step/i_smoothly_move_between_sections.dart';
import './step/i_see_my_place_in_each_section.dart';
import './step/i_am_deep_in_the_app.dart';
import './step/i_tap_back.dart';
import './step/i_go_to_the_previous_screen.dart';
import './step/i_dont_lose_my_progress.dart';

void main() {
  group('''App Navigation''', () {
    testWidgets('''Protected content requires login''', (tester) async {
      await iAmNotLoggedIn(tester);
      await iTryToViewMyVerses(tester);
      await iAmRedirectedToLoginFirst(tester);
    });
    testWidgets('''Navigate between app sections''', (tester) async {
      await iAmLoggedIn(tester);
      await iTapBetweenTabs(tester);
      await iSmoothlyMoveBetweenSections(tester);
      await iSeeMyPlaceInEachSection(tester);
    });
    testWidgets('''Back button works intuitively''', (tester) async {
      await iAmDeepInTheApp(tester);
      await iTapBack(tester);
      await iGoToThePreviousScreen(tester);
      await iDontLoseMyProgress(tester);
    });
  });
}
