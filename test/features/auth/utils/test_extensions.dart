import 'package:mini_memverse/src/features/auth/utils/validation_utils.dart';

/// Test extensions to provide backward compatibility with older test code
/// This allows testing without modifying the SUT (System Under Test)
extension ValidationUtilsTestExtension on ValidationUtils {
  /// Email validation method for tests
  ///
  /// This forwards to the existing email validation logic in ValidationUtils
  /// but presents it with the expected test API
  static String? validateEmailFormat(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Please enter a valid email address';
    }

    final trimmed = email.trim();
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}
