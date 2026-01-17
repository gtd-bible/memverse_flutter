import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/features/auth/data/auth_service.dart';
import 'package:mini_memverse/src/features/auth/presentation/providers/auth_providers.dart';

/// Test implementation of AuthService provider that enables mocking in tests
/// without modifying the System Under Test
final testAuthServiceProvider = Provider.autoDispose
    .family<AuthService, AuthServiceTestDependencies>((ref, dependencies) {
      // Return a pre-configured AuthService with dependencies injected
      return dependencies.service ??
          AuthService(
            secureStorage: dependencies.secureStorage ?? const FlutterSecureStorage(),
            dio: dependencies.dio ?? Dio(),
            appLogger: dependencies.appLogger,
          );
    });

/// Dependencies needed to create an AuthService instance in tests
class AuthServiceTestDependencies {
  /// Constructor
  const AuthServiceTestDependencies({
    required this.appLogger,
    this.secureStorage,
    this.dio,
    this.service,
  });

  /// Pre-configured logger for testing
  final AppLoggerFacade appLogger;

  /// Optional secure storage implementation
  final FlutterSecureStorage? secureStorage;

  /// Optional Dio client
  final Dio? dio;

  /// Optional complete mock service
  final AuthService? service;
}

/// Extension method to provide test-friendly override of auth service provider
extension ProviderContainerExtensions on ProviderContainer {
  /// Override auth service with a test implementation
  void overrideAuthService({
    required AppLoggerFacade logger,
    FlutterSecureStorage? secureStorage,
    Dio? dio,
    AuthService? mockService,
  }) {
    final dependencies = AuthServiceTestDependencies(
      appLogger: logger,
      secureStorage: secureStorage,
      dio: dio,
      service: mockService,
    );

    // When tests request the real authServiceProvider, intercept and provide our test version
    overrideProvider(
      authServiceProvider,
      (ref) => ref.watch(testAuthServiceProvider(dependencies)),
    );
  }
}
