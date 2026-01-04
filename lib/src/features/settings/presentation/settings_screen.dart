import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/services/analytics_manager.dart';
import 'package:mini_memverse/src/common/providers/talker_provider.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:mini_memverse/src/features/settings/presentation/analytics_provider.dart';
import 'package:mini_memverse/src/features/settings/presentation/theme_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Provider for alpha tester mode
final alphaTesterProvider = StateProvider<bool>((ref) => false);

// Provider for beta tester mode
final betaTesterProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAlphaTester = ref.watch(alphaTesterProvider);
    final isBetaTester = ref.watch(betaTesterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Account Settings
          const _SettingsHeader(title: 'Account'),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),

          // Tester Settings
          const _SettingsHeader(title: 'Tester Options'),
          SwitchListTile(
            title: const Text('Alpha Tester'),
            subtitle: const Text('Enable alpha features and testing mode'),
            value: isAlphaTester,
            onChanged: (bool value) {
              ref.read(alphaTesterProvider.notifier).state = value;
              _updateTesterProperties(value, isBetaTester);
            },
            secondary: const Icon(Icons.science),
          ),
          SwitchListTile(
            title: const Text('Beta Tester'),
            subtitle: const Text('Enable beta features and testing mode'),
            value: isBetaTester,
            onChanged: (bool value) {
              ref.read(betaTesterProvider.notifier).state = value;
              _updateTesterProperties(isAlphaTester, value);
            },
            secondary: const Icon(Icons.bug_report),
          ),

          // Logs
          const _SettingsHeader(title: 'Diagnostics'),
          ListTile(
            title: const Text('View Logs'),
            subtitle: const Text('View application logs'),
            leading: const Icon(Icons.list_alt),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TalkerScreen(talker: ref.read(talkerProvider)),
                ),
              );
            },
          ),
          Builder(
            builder: (BuildContext builderContext) {
              return ListTile(
                title: const Text('Share Logs'),
                subtitle: const Text('Share logs for debugging'),
                leading: const Icon(Icons.share),
                onTap: () async {
                  final logs = ref
                      .read(talkerProvider)
                      .history
                      .map((log) => log.generateTextMessage())
                      .join('\n');
                  final box = builderContext.findRenderObject() as RenderBox?;
                  final sharePositionOrigin = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;
                  await Share.share(logs, sharePositionOrigin: sharePositionOrigin);
                },
              );
            },
          ),

          // Theme Settings
          const _SettingsHeader(title: 'Appearance'),
          _ThemeModeSwitch(),

          // Analytics
          const _SettingsHeader(title: 'Data & Privacy'),
          _AnalyticsToggle(),
        ],
      ),
    );
  }

  void _updateTesterProperties(bool isAlpha, bool isBeta) {
    final analyticsManager = AnalyticsManager.instance;
    final crashlytics = FirebaseCrashlytics.instance;

    // Set user properties in Firebase Analytics
    analyticsManager.analytics.setUserProperty(name: 'alpha_tester', value: isAlpha.toString());
    analyticsManager.analytics.setUserProperty(name: 'beta_tester', value: isBeta.toString());

    // Set custom keys in Crashlytics
    crashlytics.setCustomKey('alpha_tester', isAlpha);
    crashlytics.setCustomKey('beta_tester', isBeta);
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ThemeModeSwitch extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return SwitchListTile(
      title: const Text('Dark Mode'),
      value: themeMode == ThemeMode.dark,
      onChanged: (bool value) {
        ref.read(themeModeProvider.notifier).state = value ? ThemeMode.dark : ThemeMode.light;
      },
      secondary: const Icon(Icons.dark_mode),
    );
  }
}

class _AnalyticsToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(analyticsEnabledProvider);

    return SwitchListTile(
      title: const Text('Share Usage Analytics'),
      value: isEnabled,
      onChanged: (bool value) {
        // Update the analytics state
        ref.read(analyticsEnabledProvider.notifier).state = value;
        // Note: Posthog opt-in/opt-out would be handled here if needed
      },
      secondary: const Icon(Icons.analytics),
    );
  }
}
