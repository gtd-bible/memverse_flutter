import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_memverse/services/app_logger_facade.dart';
import 'package:mini_memverse/src/common/providers/talker_provider.dart';
import 'package:mini_memverse/src/features/auth/utils/auth_error_handler.dart';
import 'package:mini_memverse/src/monitoring/analytics_facade.dart';

/// Provider for AuthErrorHandler
final authErrorHandlerProvider = Provider<AuthErrorHandler>((ref) {
  final analyticsFacade = ref.watch(analyticsFacadeProvider);
  final appLogger = ref.watch(appLoggerFacadeProvider);
  final talker = ref.watch(talkerProvider);

  return AuthErrorHandler(analyticsFacade: analyticsFacade, appLogger: appLogger, talker: talker);
});
