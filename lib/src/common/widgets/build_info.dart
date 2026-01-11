import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mini_memverse/services/analytics_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Provider for PackageInfo, giving access to app version, build number, etc.
final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

class BuildInfoText extends ConsumerWidget {
  final TextStyle? style;
  final TextAlign textAlign;

  const BuildInfoText({this.style, this.textAlign = TextAlign.center, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return packageInfoAsync.when(
      data: (packageInfo) {
        final buildType = AnalyticsManager.testerType.contains('beta')
            ? 'beta build'
            : AnalyticsManager.testerType.contains('alpha')
            ? 'alpha build'
            : 'release build';

        final versionString = 'v${packageInfo.version}+${packageInfo.buildNumber} ($buildType)';

        return Text(
          versionString,
          style: style ?? Theme.of(context).textTheme.bodySmall,
          textAlign: textAlign,
        );
      },
      loading: () => const SizedBox(), // Empty widget while loading
      error: (_, __) => const SizedBox(), // Empty widget on error
    );
  }
}
