// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_have_a_verse_open_in_demo_mode.dart';
import './step/i_tap_blur.dart';
import './step/some_words_become_hidden.dart';
import './step/i_can_try_to_recall_the_hidden_words.dart';
import './step/i_have_started_blurring.dart';
import './step/i_tap_blur_more.dart';
import './step/even_more_words_disappear.dart';
import './step/i_must_rely_more_on_memory.dart';
import './step/many_words_are_hidden.dart';
import './step/i_tap_blur_less.dart';
import './step/i_see_more_of_the_text.dart';
import './step/i_can_verify_what_i_remembered.dart';
import './step/i_keep_tapping_blur_more.dart';
import './step/eventually_most_words_are_hidden.dart';
import './step/i_can_test_complete_memorization.dart';

void main() {
  group('''Progressive Memory Practice with Blur''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await iHaveAVerseOpenInDemoMode(tester);
    }

    testWidgets('''Start practicing with blur''', (tester) async {
      await bddSetUp(tester);
      await iTapBlur(tester);
      await someWordsBecomeHidden(tester);
      await iCanTryToRecallTheHiddenWords(tester);
    });
    testWidgets('''Make it harder by hiding more''', (tester) async {
      await bddSetUp(tester);
      await iHaveStartedBlurring(tester);
      await iTapBlurMore(tester);
      await evenMoreWordsDisappear(tester);
      await iMustRelyMoreOnMemory(tester);
    });
    testWidgets('''Check my work by revealing words''', (tester) async {
      await bddSetUp(tester);
      await manyWordsAreHidden(tester);
      await iTapBlurLess(tester);
      await iSeeMoreOfTheText(tester);
      await iCanVerifyWhatIRemembered(tester);
    });
    testWidgets('''Full memorization challenge''', (tester) async {
      await bddSetUp(tester);
      await iKeepTappingBlurMore(tester);
      await eventuallyMostWordsAreHidden(tester);
      await iCanTestCompleteMemorization(tester);
    });
  });
}
