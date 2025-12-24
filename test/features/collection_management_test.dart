// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_am_in_demo_mode.dart';
import './step/i_have_verses_in_multiple_collections.dart';
import './step/i_tap_the_collections_button.dart';
import './step/i_see_a_list_of_all_my_collections.dart';
import './step/each_shows_its_name.dart';
import './step/the_current_collection_is_highlighted.dart';
import './step/i_am_viewing_daily_verses.dart';
import './step/i_select_memory_work.dart';
import './step/i_see_verses_from_memory_work.dart';
import './step/the_screen_title_shows_memory_work.dart';
import './step/i_am_viewing_my_list.dart';
import './step/i_tap_the_edit_button_next_to_the_collection_name.dart';
import './step/i_enter_favorite_psalms_as_the_new_name.dart';
import './step/i_confirm.dart';
import './step/the_collection_is_renamed_to_favorite_psalms.dart';
import './step/all_verses_remain_in_the_collection.dart';
import './step/i_create_a_collection_called_wedding_verses.dart';
import './step/i_add5_verses_to_it.dart';
import './step/i_close_and_reopen_the_app.dart';
import './step/wedding_verses_is_still_there.dart';
import './step/all5_verses_are_intact.dart';
import './step/i_add_a_new_verse.dart';
import './step/i_specify_special_collection_as_the_list.dart';
import './step/the_verse_is_added_to_special_collection.dart';
import './step/i_remain_viewing_daily_verses.dart';
import './step/i_create_a_new_empty_collection.dart';
import './step/i_view_that_collection.dart';
import './step/i_see_no_verses_in_this_list.dart';
import './step/i_see_the_add_button_to_start_adding_verses.dart';
import './step/i_am_viewing_a_collection.dart';
import './step/i_pull_down_on_the_list.dart';
import './step/the_list_refreshes.dart';
import './step/any_changes_are_loaded.dart';

void main() {
  group('''Collection Management''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await iAmInDemoMode(tester);
      await iHaveVersesInMultipleCollections(tester);
    }

    testWidgets('''View all my collections''', (tester) async {
      await bddSetUp(tester);
      await iTapTheCollectionsButton(tester);
      await iSeeAListOfAllMyCollections(tester);
      await eachShowsItsName(tester);
      await theCurrentCollectionIsHighlighted(tester);
    });
    testWidgets('''Switch between collections''', (tester) async {
      await bddSetUp(tester);
      await iAmViewingDailyVerses(tester);
      await iTapTheCollectionsButton(tester);
      await iSelectMemoryWork(tester);
      await iSeeVersesFromMemoryWork(tester);
      await theScreenTitleShowsMemoryWork(tester);
    });
    testWidgets('''Rename a collection''', (tester) async {
      await bddSetUp(tester);
      await iAmViewingMyList(tester);
      await iTapTheEditButtonNextToTheCollectionName(tester);
      await iEnterFavoritePsalmsAsTheNewName(tester);
      await iConfirm(tester);
      await theCollectionIsRenamedToFavoritePsalms(tester);
      await allVersesRemainInTheCollection(tester);
    });
    testWidgets('''Collection persists across app restarts''', (tester) async {
      await bddSetUp(tester);
      await iCreateACollectionCalledWeddingVerses(tester);
      await iAdd5VersesToIt(tester);
      await iCloseAndReopenTheApp(tester);
      await weddingVersesIsStillThere(tester);
      await all5VersesAreIntact(tester);
    });
    testWidgets('''Add verse to different collection''', (tester) async {
      await bddSetUp(tester);
      await iAmViewingDailyVerses(tester);
      await iAddANewVerse(tester);
      await iSpecifySpecialCollectionAsTheList(tester);
      await theVerseIsAddedToSpecialCollection(tester);
      await iRemainViewingDailyVerses(tester);
    });
    testWidgets('''Empty collection shows helpful message''', (tester) async {
      await bddSetUp(tester);
      await iCreateANewEmptyCollection(tester);
      await iViewThatCollection(tester);
      await iSeeNoVersesInThisList(tester);
      await iSeeTheAddButtonToStartAddingVerses(tester);
    });
    testWidgets('''Pull to refresh updates verse list''', (tester) async {
      await bddSetUp(tester);
      await iAmViewingACollection(tester);
      await iPullDownOnTheList(tester);
      await theListRefreshes(tester);
      await anyChangesAreLoaded(tester);
    });
  });
}
