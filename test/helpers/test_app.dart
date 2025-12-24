import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:memverse_flutter/src/app.dart';
import 'package:memverse_flutter/src/features/demo/presentation/views/demo_home_screen.dart';
import 'package:memverse_flutter/src/features/demo/presentation/demo_providers.dart';
import 'package:memverse_flutter/src/services/database.dart';
import 'package:memverse_flutter/src/features/demo/data/scripture.dart';

// Mocks for testing
class MockGoRouter extends Mock implements GoRouter {}

class MockGoRouterNotifier extends Mock implements ChangeNotifier {}

class MockDatabase extends Mock implements Database {
  final MockIsar mockIsar;
  MockDatabase(this.mockIsar);

  @override
  Future<void> init() async {
    // Simulate init
  }

  @override
  Isar get isar => mockIsar;
}

class MockIsar extends Mock implements Isar {
  // Mock the scriptures collection getter
  @override
  IsarCollection<Scripture> get scriptures => MockIsarCollection();
}

class MockIsarCollection extends Mock implements IsarCollection<Scripture> {}

// A test app that allows overriding providers
class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    this.overrides = const [],
    this.initialLocation,
    this.child,
  });

  final List<Override> overrides;
  final String? initialLocation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // Mock the GoRouter and its notifier if an initialLocation is provided
    final mockRouter = MockGoRouter();
    final mockNotifier = MockGoRouterNotifier();

    if (initialLocation != null) {
      when(() => mockRouter.routeInformationParser).thenReturn(
        GoRouter(initialLocation: initialLocation, routes: []).routeInformationParser,
      );
      when(() => mockRouter.routerDelegate).thenReturn(
        GoRouter(initialLocation: initialLocation, routes: []).routerDelegate,
      );
      when(() => mockRouter.go(any())).thenAnswer((_) => Future.value());
      when(() => mockRouter.push(any())).thenAnswer((_) => Future.value());
      when(() => mockRouter.pop()).thenAnswer((_) => true);
      when(() => mockRouter.refreshListenable).thenReturn(mockNotifier);
    }

    final app = MaterialApp.router(
      title: 'Memverse Test App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: initialLocation != null
          ? mockRouter
          : GoRouter(
              initialLocation: initialLocation ?? '/',
              routes: [
                GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
                GoRoute(path: '/demo', builder: (context, state) => const DemoHomeScreen()),
                GoRoute(path: '/login', builder: (context, state) => const Text('Login Screen')),
                GoRoute(
                    path: '/memverse-home',
                    builder: (context, state) => const Text('Memverse Home Screen')),
              ],
            ),
    );

    return ProviderScope(
      overrides: [
        if (initialLocation != null) routerProvider.overrideWithValue(mockRouter),
        ...overrides,
      ],
      child: child ?? app,
    );
  }
}
