// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_am_using_the_app_in_demo_mode.dart';
import './step/i_tap_the_add_button.dart';
import './step/i_enter_john316_as_the_reference.dart';
import './step/i_enter_my_first_verses_as_the_collection.dart';
import './step/i_submit_the_form.dart';
import './step/the_verse_is_fetched_from_the_api.dart';
import './step/john316_appears_in_my_list.dart';
import './step/i_see_the_verse_text_for_god_so_loved_the_world.dart';
import './step/i_have_john316_in_my_collection.dart';
import './step/i_tap_on_the_verse.dart';
import './step/i_see_the_full_verse_text.dart';
import './step/i_tap_blur_to_start_practicing.dart';
import './step/some_words_become_hidden.dart';
import './step/i_tap_blur_more.dart';
import './step/more_words_are_hidden.dart';
import './step/i_can_test_my_memory.dart';
import './step/i_am_practicing_a_verse_with_blur.dart';
import './step/i_tap_blur_less.dart';
import './step/fewer_words_are_hidden.dart';
import './step/i_can_see_if_i_remembered_correctly.dart';
import './step/i_have_added_several_verses.dart';
import './step/i_tap_the_collections_menu.dart';
import './step/i_see_all_my_collections.dart';
import './step/i_tap_create_new_collection.dart';
import './step/i_name_it_comfort_verses.dart';
import './step/i_can_add_verses_to_that_collection.dart';
import './step/i_have_philippians413_in_my_list.dart';
import './step/i_tap_the_share_button.dart';
import './step/the_share_dialog_opens.dart';
import './step/the_verse_and_reference_are_ready_to_share.dart';
import './step/i_have_verses_in_my_collection.dart';
import './step/i_swipe_left_on_a_verse.dart';
import './step/i_tap_delete.dart';
import './step/the_verse_is_removed_from_my_collection.dart';
import './step/i_enter_romans828_proverbs356_matthew633.dart';
import './step/all_three_verses_are_added.dart';
import './step/i_see3_new_verses_in_my_list.dart';
import './step/i_have10_verses_in_my_collection.dart';
import './step/i_open_any_verse.dart';
import './step/i_practice_with_blur.dart';
import './step/i_move_to_the_next_verse.dart';
import './step/i_can_practice_multiple_verses_in_succession.dart';

void main() {
  group('''Scripture Memorization Journey''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await iAmUsingTheAppInDemoMode(tester);
    }

    testWidgets('''Add my first scripture verse''', (tester) async {
      await bddSetUp(tester);
      await iTapTheAddButton(tester);
      await iEnterJohn316AsTheReference(tester);
      await iEnterMyFirstVersesAsTheCollection(tester);
      await iSubmitTheForm(tester);
      await theVerseIsFetchedFromTheApi(tester);
      await john316AppearsInMyList(tester);
      await iSeeTheVerseTextForGodSoLovedTheWorld(tester);
    });
    testWidgets('''Practice memorization with blur''', (tester) async {
      await bddSetUp(tester);
      await iHaveJohn316InMyCollection(tester);
      await iTapOnTheVerse(tester);
      await iSeeTheFullVerseText(tester);
      await iTapBlurToStartPracticing(tester);
      await someWordsBecomeHidden(tester);
      await iTapBlurMore(tester);
      await moreWordsAreHidden(tester);
      await iCanTestMyMemory(tester);
    });
    testWidgets('''Reduce blur to check my work''', (tester) async {
      await bddSetUp(tester);
      await iAmPracticingAVerseWithBlur(tester);
      await iTapBlurLess(tester);
      await fewerWordsAreHidden(tester);
      await iCanSeeIfIRememberedCorrectly(tester);
    });
    testWidgets('''Organize verses into collections''', (tester) async {
      await bddSetUp(tester);
      await iHaveAddedSeveralVerses(tester);
      await iTapTheCollectionsMenu(tester);
      await iSeeAllMyCollections(tester);
      await iTapCreateNewCollection(tester);
      await iNameItComfortVerses(tester);
      await iCanAddVersesToThatCollection(tester);
    });
    testWidgets('''Share a meaningful verse''', (tester) async {
      await bddSetUp(tester);
      await iHavePhilippians413InMyList(tester);
      await iTapOnTheVerse(tester);
      await iTapTheShareButton(tester);
      await theShareDialogOpens(tester);
      await theVerseAndReferenceAreReadyToShare(tester);
    });
    testWidgets('''Remove a verse I no longer need''', (tester) async {
      await bddSetUp(tester);
      await iHaveVersesInMyCollection(tester);
      await iSwipeLeftOnAVerse(tester);
      await iTapDelete(tester);
      await theVerseIsRemovedFromMyCollection(tester);
    });
    testWidgets('''Batch add multiple verses''', (tester) async {
      await bddSetUp(tester);
      await iTapTheAddButton(tester);
      await iEnterRomans828Proverbs356Matthew633(tester);
      await iSubmitTheForm(tester);
      await allThreeVersesAreAdded(tester);
      await iSee3NewVersesInMyList(tester);
    });
    testWidgets('''Quick practice session''', (tester) async {
      await bddSetUp(tester);
      await iHave10VersesInMyCollection(tester);
      await iOpenAnyVerse(tester);
      await iPracticeWithBlur(tester);
      await iMoveToTheNextVerse(tester);
      await iCanPracticeMultipleVersesInSuccession(tester);
    });
  });
}
