/// Compile-time constants from dart-define.
///
/// IMPORTANT: These values are provided at build time using --dart-define flags.
/// To run the app locally, use the following command format:
///
/// ```bash
/// flutter run \
///   --dart-define=MEMVERSE_CLIENT_ID=your_client_id \
///   --dart-define=MEMVERSE_CLIENT_API_KEY=your_client_api_key \
///   --dart-define=TESTER_TYPE=your_tester_type
/// ```
///
/// For deployment, these values are set in the deployment scripts:
/// - See `scripts/deploy_ios.sh`
/// - See README.md for more information

/// Authentication
/// The client ID used to authenticate with the Memverse API
const memverseClientId = String.fromEnvironment('MEMVERSE_CLIENT_ID');

/// The client secret (API key) used to authenticate with the Memverse API
const memverseClientSecret = String.fromEnvironment('MEMVERSE_CLIENT_API_KEY');

/// Testing
/// For automated testing, these credentials can be provided at test time
const testUsername = String.fromEnvironment('MEMVERSE_USERNAME');
const testPassword = String.fromEnvironment('MEMVERSE_CORRECT_PASSWORD_DO_NOT_COMMIT');

/// Deployment
/// Identifies the deployment channel or tester group
/// Possible values: 'firebase_alpha_ios', 'testflight_beta_ios', etc.
const testerType = String.fromEnvironment('TESTER_TYPE', defaultValue: '');
