// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_starts.dart';
import './step/i_see_scripture_app_demo.dart';
import './step/i_see_add_scripture.dart';

void main() {
  group('''Demo Mode''', () {
    testWidgets('''View demo home screen''', (tester) async {
      await theAppStarts(tester);
      await iSeeScriptureAppDemo(tester);
      await iSeeAddScripture(tester);
    });
  });
}
