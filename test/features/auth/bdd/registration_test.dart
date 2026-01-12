// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_am_on_the_login_screen.dart';
import './step/i_tap_the_create_account_link.dart';
import './step/i_should_see_the_registration_form.dart';
import './step/i_am_on_the_signup_screen.dart';
import './step/i_submit_the_form_without_filling_any_fields.dart';
import './step/i_should_see_validation_error_messages.dart';
import './step/i_should_remain_on_the_signup_screen.dart';
import './step/i_enter_invalidemail_in_the_email_field.dart';
import './step/i_enter_password123_in_the_password_field.dart';
import './step/i_enter_password123_in_the_confirm_password_field.dart';
import './step/i_submit_the_form.dart';
import './step/i_should_see_an_email_validation_error.dart';
import './step/i_enter_validexamplecom_in_the_email_field.dart';
import './step/i_enter_differentpassword_in_the_confirm_password_field.dart';
import './step/i_should_see_a_password_mismatch_error.dart';
import './step/i_enter_newuserexamplecom_in_the_email_field.dart';
import './step/i_enter_securepassword123_in_the_password_field.dart';
import './step/i_enter_securepassword123_in_the_confirm_password_field.dart';
import './step/i_should_see_a_loading_indicator.dart';
import './step/signup_analytics_event_should_be_triggered.dart';

void main() {
  group('''User Registration''', () {
    testWidgets('''User navigates to signup page from login screen''',
        (tester) async {
      await iAmOnTheLoginScreen(tester);
      await iTapTheCreateAccountLink(tester);
      await iShouldSeeTheRegistrationForm(tester);
    });
    testWidgets('''User submits signup form with empty fields''',
        (tester) async {
      await iAmOnTheSignupScreen(tester);
      await iSubmitTheFormWithoutFillingAnyFields(tester);
      await iShouldSeeValidationErrorMessages(tester);
      await iShouldRemainOnTheSignupScreen(tester);
    });
    testWidgets('''User submits signup form with invalid email''',
        (tester) async {
      await iAmOnTheSignupScreen(tester);
      await iEnterInvalidemailInTheEmailField(tester);
      await iEnterPassword123InThePasswordField(tester);
      await iEnterPassword123InTheConfirmPasswordField(tester);
      await iSubmitTheForm(tester);
      await iShouldSeeAnEmailValidationError(tester);
      await iShouldRemainOnTheSignupScreen(tester);
    });
    testWidgets('''User submits signup form with mismatched passwords''',
        (tester) async {
      await iAmOnTheSignupScreen(tester);
      await iEnterValidexamplecomInTheEmailField(tester);
      await iEnterPassword123InThePasswordField(tester);
      await iEnterDifferentpasswordInTheConfirmPasswordField(tester);
      await iSubmitTheForm(tester);
      await iShouldSeeAPasswordMismatchError(tester);
      await iShouldRemainOnTheSignupScreen(tester);
    });
    testWidgets('''User submits signup form with valid data''', (tester) async {
      await iAmOnTheSignupScreen(tester);
      await iEnterNewuserexamplecomInTheEmailField(tester);
      await iEnterSecurepassword123InThePasswordField(tester);
      await iEnterSecurepassword123InTheConfirmPasswordField(tester);
      await iSubmitTheForm(tester);
      await iShouldSeeALoadingIndicator(tester);
      await signupAnalyticsEventShouldBeTriggered(tester);
    });
  });
}
