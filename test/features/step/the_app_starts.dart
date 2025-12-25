import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memverse_flutter/src/features/demo/data/scripture.dart';
import 'package:memverse_flutter/src/features/demo/presentation/views/demo_home_screen.dart';
import 'package:memverse_flutter/src/services/database_repository  child: MaterialApp(
        home: DemoHomeScreen(),
      ),
    ),
  );
  // Give the app time to initialize
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}
