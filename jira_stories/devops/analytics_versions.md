# Story: Distinguish Builds in Analytics

**Story Point Estimate:** 2
**Priority:** Medium

## Description
We need to distinguish between development, beta (TestFlight/Open Beta), and production builds in Firebase Analytics.

## Requirements
1.  Use `--dart-define` or `flavor` configuration.
2.  Inject properties like `environment`: "dev", "beta", "prod".
3.  Log a user property `flutter_app_version_type` on initialization.
4.  Ensure `firebase_analytics` is properly configured to send these distinct signals.
