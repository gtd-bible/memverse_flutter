// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';
import './step/i_am_reviewing_a_verse.dart';
import './step/i_tap_the5star_rating_button.dart';
import './step/i_see_a_success_message.dart';
import './step/the_rating_is_saved.dart';

void main() {
  group('''Rate Verse''', () {
    testWidgets('''User rates a verse with 5 stars''', (tester) async {
      await theAppIsRunning(tester);
      await iAmReviewingAVerse(tester);
      await iTapThe5starRatingButton(tester);
      await iSeeASuccessMessage(tester);
      await theRatingIsSaved(tester);
    });
  });
}
