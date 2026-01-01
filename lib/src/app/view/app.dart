import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mini_memverse/src/common/providers/talker_provider.dart';
import 'package:mini_memverse/src/constants/themes.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/presentation/auth_wrapper.dart';
import 'package:mini_memverse/src/features/settings/presentation/theme_provider.dart';
import 'package:mini_memverse/src/features/signed_in/presentation/signed_in_nav_scaffold.dart';
import 'package:talker_flutter/talker_flutter.dart';

late ProviderContainer container;

Talker get talker => container.read(talkerProvider);

class App extends ConsumerWidget {
  static void initialize() {
    container = ProviderContainer(overrides: []);
  }

  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Builder(
      builder: (context) {
        final isDarkMode =
            themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return UncontrolledProviderScope(
          container: container,
          child: BetterFeedback(
            theme: isDarkMode ? AppThemes.feedbackDarkTheme : AppThemes.feedbackTheme,
            child: TalkerWrapper(
              talker: talker,
              options: const TalkerWrapperOptions(enableErrorAlerts: true),
              child: MaterialApp(
                theme: AppThemes.light,
                darkTheme: AppThemes.dark,
                themeMode: themeMode,
                home: AuthService.isDummyUser ? const SignedInNavScaffold() : const AuthWrapper(),
              ),
            ),
          ),
        );
      },
    );
  }
}
