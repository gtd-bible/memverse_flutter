/// Stub implementation for production code
///
/// This provides non-test implementations of the utilities in test_utils.dart
/// which should only be used in tests. This ensures production code doesn't
/// contain test-specific logic.
library test_utils_stub;

/// Mock Dio class for type checking in production code
class TestMockDio {
  // Empty implementation - just used for type checking
}

/// Extension to allow any object to be checked if it's a mock
extension DioTypeCheck on dynamic {
  /// Always returns false in production code - no mocks should exist
  bool get isTestMockDio => false;
}
