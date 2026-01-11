import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';

import '../constants/app_constants.dart';

/// Utility class for debug-only features.
///
/// This class contains utility methods that are only available in debug mode
/// to assist with development and testing. These features are automatically
/// disabled in release builds for security.
class DebugModeUtils {
  /// Private constructor to prevent instantiation
  DebugModeUtils._();

  /// Checks if debug mode is active and debug features are available
  static bool get isDebugModeEnabled => kDebugMode;

  /// Get debug credentials from environment variables
  static ({String username, String password}) getDebugCredentials() {
    // Use the centralized test credentials from app_constants.dart
    const username = testUsername;
    const password = testPassword;

    return (username: username, password: password);
  }

  /// Check if debug credentials are available
  static bool hasDebugCredentials() {
    if (!kDebugMode) return false;

    final credentials = getDebugCredentials();
    return credentials.username.isNotEmpty && credentials.password.isNotEmpty;
  }

  /// Auto-login using environment variables
  /// Returns true if login was attempted, false otherwise
  static Future<bool> autoLoginWithDebugCredentials({
    required BuildContext context,
    required WidgetRef ref,
    required TextEditingController usernameController,
    required TextEditingController passwordController,
    bool showSnackbar = true,
  }) async {
    if (!kDebugMode) {
      debugPrint('❌ DEBUG: Auto-login skipped - not in debug mode');
      return false;
    }

    final authState = ref.read(authStateProvider);
    if (authState.isLoading) {
      debugPrint('❌ DEBUG: Auto-login skipped - auth state is already loading');
      return false;
    }

    final credentials = getDebugCredentials();
    debugPrint(
      '🔐 DEBUG: Got credentials - username length: ${credentials.username.length}, password length: ${credentials.password.length}',
    );

    // Only proceed if environment variables are set
    if (credentials.username.isNotEmpty && credentials.password.isNotEmpty) {
      // Set the text fields (for visual feedback)
      usernameController.text = credentials.username;
      passwordController.text = credentials.password;
      debugPrint('✓ DEBUG: Set text fields to environment credentials');

      if (showSnackbar && context.mounted) {
        // Show a snackbar indicating login is being attempted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logging in with email: ${credentials.username} and password: [REDACTED]',
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
        debugPrint('ℹ️ DEBUG: Showed auto-login snackbar');
      }

      try {
        debugPrint('🔄 DEBUG: About to call login on authStateProvider notifier');
        // Perform the login operation directly
        await ref
            .read(authStateProvider.notifier)
            .login(credentials.username, credentials.password);
        debugPrint('✅ DEBUG: Login call completed successfully');
        return true;
      } catch (e) {
        debugPrint('❌ DEBUG: Error during auto-login: $e');
        if (showSnackbar && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Auto-login failed: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return false;
      }
    } else {
      debugPrint('❌ DEBUG: Environment variables not set properly');
      if (showSnackbar && context.mounted) {
        // Show warning if environment variables are not set
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Environment variables MEMVERSE_USERNAME or MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT not set',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }

  /// Widget extension to add debug mode tooltip and icon
  static Widget addDebugIndicator(Widget child, String tooltip) {
    if (!kDebugMode) return child;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        child,
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Tooltip(
            message: 'Debug mode feature',
            child: Icon(Icons.bug_report, size: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

/// Extension on BuildContext to provide easy access to debug utilities
extension DebugBuildContextExtension on BuildContext {
  /// Show a debug-only snackbar (only appears in debug mode)
  void showDebugSnackbar(
    String message, {
    Color backgroundColor = Colors.orange,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!kDebugMode) return;

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor, duration: duration),
    );
  }
}
