/// Utility class for validating user input
///
/// Contains methods for validating usernames, passwords, and other input fields
/// based on server-side requirements.
class ValidationUtils {
  /// Validates a username
  ///
  /// Requirements:
  /// - Not empty after trimming
  /// - At least 3 characters
  /// - At most 50 characters
  /// - Contains a valid email format if it's an email
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Please enter your username or email';
    }

    final trimmed = username.trim();

    if (trimmed.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (trimmed.length > 50) {
      return 'Username must be less than 50 characters';
    }

    // If it contains @ symbol, validate as email
    if (trimmed.contains('@')) {
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(trimmed)) {
        return 'Please enter a valid email address';
      }
    }

    return null;
  }

  /// Validates a password
  ///
  /// Requirements:
  /// - Not empty after trimming
  /// - At least 8 characters
  /// - At most 100 characters
  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'Please enter your password';
    }

    final trimmed = password.trim();

    if (trimmed.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (trimmed.length > 100) {
      return 'Password must be less than 100 characters';
    }

    return null;
  }

  /// Helper method to check if the string is a valid username
  static bool isValidUsername(String? username) {
    return validateUsername(username) == null;
  }

  /// Helper method to check if the string is a valid password
  static bool isValidPassword(String? password) {
    return validatePassword(password) == null;
  }
}

/// Extension methods for String to add validation functionality
extension StringValidationExtension on String {
  /// Returns true if the string is a valid username
  bool get isValidUsername {
    return ValidationUtils.isValidUsername(this);
  }

  /// Returns true if the string is a valid password
  bool get isValidPassword {
    return ValidationUtils.isValidPassword(this);
  }

  /// Returns true if the string contains a valid email format
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(trim());
  }
}
