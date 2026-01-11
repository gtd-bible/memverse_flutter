# Memverse Flutter App

A mobile application for Memverse.com that helps users memorize Bible verses.

## Getting Started

### Prerequisites

- Flutter SDK 3.10.4 or higher
- Dart SDK 3.0.0 or higher
- Firebase project setup with Analytics and Crashlytics

### Environment Setup

The app requires the following environment variables to be set:

```bash
flutter run \
  --dart-define=MEMVERSE_CLIENT_ID=$MEMVERSE_CLIENT_ID \
  --dart-define=MEMVERSE_CLIENT_API_KEY=$MEMVERSE_CLIENT_API_KEY
```

### Analytics & Crashlytics

This app uses a custom analytics architecture based on [Code With Andrea's article on Flutter App Analytics](https://codewithandrea.com/articles/flutter-app-analytics/).

The analytics implementation follows these patterns:

- An `AnalyticsClient` interface that defines all trackable events
- Concrete implementations for Firebase (`FirebaseAnalyticsClient`) and logging (`LoggerAnalyticsClient`)
- An `AnalyticsFacade` that can dispatch to multiple clients
- Debug mode logging vs Release mode analytics

For error reporting, the app uses Firebase Crashlytics with a custom `CrashlyticsTalkerObserver` that integrates with the Talker package for comprehensive error reporting.

### Testing

The app includes comprehensive tests for the analytics and crashlytics implementations:

```bash
flutter test test/src/monitoring/
flutter test test/services/
```

## Project Structure

- `lib/src/monitoring/` - Analytics and error tracking implementation
- `lib/services/` - Core services including AnalyticsManager
- `test/src/monitoring/` - Tests for analytics and error tracking

## Building

To build the app for production:

```bash
flutter build apk --release
flutter build ios --release
```

## Development

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.