import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Class to hold bootstrap values
class BootstrapValues {
  /// Constructor
  const BootstrapValues({required this.clientId, required this.clientSecret});

  /// The client ID used for authentication
  final String clientId;

  /// The client secret/API key used for authentication
  final String clientSecret;
}

/// Provider for bootstrap values
final bootstrapProvider = Provider<BootstrapValues>((ref) {
  // Get the client ID and secret from centralized app constants
  const clientId = memverseClientId;
  const memVerseClientSecret = memverseClientSecret;

  // Validate that the MEMVERSE_CLIENT_ID is provided
  if (clientId.isEmpty) {
    throw Exception(
      'MEMVERSE_CLIENT_ID environment variable is not defined. '
      'Please run with --dart-define=MEMVERSE_CLIENT_ID=your_client_id',
    );
  }

  // Validate that the CLIENT_API_KEY is provided
  if (memVerseClientSecret.isEmpty) {
    throw Exception(
      'MEMVERSE_CLIENT_API_KEY environment variable is not defined. '
      'Please run with --dart-define=MEMVERSE_CLIENT_API_KEY=your_client_api_key',
    );
  }

  return BootstrapValues(clientId: clientId, clientSecret: memVerseClientSecret);
});
