// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_am_using_the_app.dart';
import './step/i_am_adding_a_new_verse.dart';
import './step/i_enter_invalid9999_as_the_reference.dart';
import './step/i_submit_the_form.dart';
import './step/i_see_an_error_message.dart';
import './step/the_verse_is_not_added.dart';
import './step/i_can_try_again_with_a_different_reference.dart';
import './step/i_tap_submit_without_entering_anything.dart';
import './step/i_see_please_enter_some_text_on_the_reference_field.dart';
import './step/the_form_does_not_submit.dart';
import './step/the_network_is_unavailable.dart';
import './step/i_try_to_add_john316.dart';
import './step/i_see_a_helpful_error_message.dart';
import './step/i_can_retry_when_network_returns.dart';
import './step/i_am_on_the_login_screen.dart';
import './step/i_enter_wrong_credentials.dart';
import './step/i_tap_login.dart';
import './step/i_see_invalid_username_or_password.dart';
import './step/i_can_try_again.dart';
import './step/my_previous_username_is_still_filled_in.dart';
import './step/i_am_adding_a_verse.dart';
import './step/i_enter_this_is_not_a_reference.dart';
import './step/i_submit.dart';
import './step/i_see_an_appropriate_error.dart';
import './step/the_form_stays_open_for_correction.dart';
import './step/i_am_offline.dart';
import './step/i_try_to_add_a_new_verse.dart';
import './step/i_see_network_unavailable_message.dart';
import './step/i_can_still_view_my_existing_verses.dart';
import './step/i_can_still_practice_with_blur.dart';
import './step/deletion_fails_due_to_database_error.dart';
import './step/i_try_to_delete_a_verse.dart';
import './step/the_verse_remains_in_the_list.dart';

void main() {
  group('''Error Handling and Recovery''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await iAmUsingTheApp(tester);
    }

    testWidgets('''Invalid scripture reference''', (tester) async {
      await bddSetUp(tester);
      await iAmAddingANewVerse(tester);
      await iEnterInvalid9999AsTheReference(tester);
      await iSubmitTheForm(tester);
      await iSeeAnErrorMessage(tester);
      await theVerseIsNotAdded(tester);
      await iCanTryAgainWithADifferentReference(tester);
    });
    testWidgets('''Empty form validation''', (tester) async {
      await bddSetUp(tester);
      await iAmAddingANewVerse(tester);
      await iTapSubmitWithoutEnteringAnything(tester);
      await iSeePleaseEnterSomeTextOnTheReferenceField(tester);
      await theFormDoesNotSubmit(tester);
    });
    testWidgets('''Network error during scripture fetch''', (tester) async {
      await bddSetUp(tester);
      await theNetworkIsUnavailable(tester);
      await iTryToAddJohn316(tester);
      await iSeeAHelpfulErrorMessage(tester);
      await iCanRetryWhenNetworkReturns(tester);
    });
    testWidgets('''Invalid login credentials''', (tester) async {
      await bddSetUp(tester);
      await iAmOnTheLoginScreen(tester);
      await iEnterWrongCredentials(tester);
      await iTapLogin(tester);
      await iSeeInvalidUsernameOrPassword(tester);
      await iCanTryAgain(tester);
      await myPreviousUsernameIsStillFilledIn(tester);
    });
    testWidgets('''Malformed verse reference''', (tester) async {
      await bddSetUp(tester);
      await iAmAddingAVerse(tester);
      await iEnterThisIsNotAReference(tester);
      await iSubmit(tester);
      await iSeeAnAppropriateError(tester);
      await theFormStaysOpenForCorrection(tester);
    });
    testWidgets('''Graceful degradation without network''', (tester) async {
      await bddSetUp(tester);
      await iAmOffline(tester);
      await iTryToAddANewVerse(tester);
      await iSeeNetworkUnavailableMessage(tester);
      await iCanStillViewMyExistingVerses(tester);
      await iCanStillPracticeWithBlur(tester);
    });
    testWidgets('''Error recovery after failed deletion''', (tester) async {
      await bddSetUp(tester);
      await deletionFailsDueToDatabaseError(tester);
      await iTryToDeleteAVerse(tester);
      await iSeeAnErrorMessage(tester);
      await theVerseRemainsInTheList(tester);
      await iCanTryAgain(tester);
    });
  });
}
