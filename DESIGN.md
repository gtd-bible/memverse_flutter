# Design Document: Memverse Flutter App

## Overview
The goal is to create a unified Flutter application, `memverse_flutter`, that combines the functionality of two existing projects:
1.  **Scripture App**: Serves as the "Demo Mode" (guest access, local storage).
2.  **Memverse Project**: Serves as the "Signed-In Mode" (full account functionality, API integration).

The app will use `com.spiritflightapps.memverse` as the package ID/Bundle ID.
The Dart package name will be `memverse_flutter`.

## Architecture

### Project Structure
We will adopt the **Feature-First** architecture found in `memverse_project`.

```
lib/
├── src/
│   ├── app.dart           # Main App Widget & Routing
│   ├── features/
│   │   ├── auth/          # Authentication (from memverse_project)
│   │   ├── demo/          # Demo Mode (from scripture-app)
│   │   └── memverse/      # Core Memverse Features (from memverse_project)
│   ├── utils/             # Shared utilities
│   └── services/          # Shared services (API, Database)
├── main.dart              # Entry point
└── ...
```

### State Management
**Riverpod** will be the standard state management solution.

### Navigation
**GoRouter** will be the standard routing package.
-   The `scripture-app` navigation (currently using `Navigator`) will be refactored to use `GoRouter`.
-   A top-level redirect or landing page will handle routing between "Demo Mode" and "Signed-In Mode".

### Data Layer
-   **Demo Mode**: Uses **Isar** for local data persistence.
    -   *Web Support*: Isar supports Web (via IndexedDB). We must ensure the initialization covers Web.
-   **Signed-In Mode**: Uses **Dio/Retrofit** for API interactions.

## Web Support & Constraints
The application will support **Android**, **iOS**, and **Web**.

**Crucial Web Constraint:**
Due to CORS limitations with the Memverse backend, **Signed-In Mode will NOT be available on Web**.
-   On the **Web** platform, the "Sign In" / "Sign Up" UI must be replaced with a message:
    > "Please download android or ios app for more features"
-   **Demo Mode** must still function fully on Web.

## Migration Strategy

### Phase 1: Foundation
-   Initialize `memverse_flutter`.
-   Setup `pubspec.yaml` with combined dependencies.
-   Setup `GoRouter` configuration.
-   Configure `build.gradle` for Android (incorporating Release config patterns from `memverse_project` / `Memverse`).

### Phase 2: Demo Mode (Scripture App)
-   Port `scripture-app/lib` code into `lib/src/features/demo`.
-   Refactor `Navigator` calls to `GoRouter`.
-   Ensure Isar database initialization works for Mobile and Web.
-   Remove "Firebase Remote Config" dependency for Demo Mode.

### Phase 3: Signed-In Mode (Memverse Project)
-   Port `memverse_project/lib` code into `lib/src/features/memverse`.
-   Integrate Authentication logic.
-   **Implement Platform-Specific UI for Auth:**
    -   If `kIsWeb`: Show "Download App" message.
    -   If Mobile: Show Login/Signup Forms.

### Phase 4: Integration
-   Implement the "Switch" / Landing logic:
    -   User opens app -> Check Auth (if mobile) or show Landing.
    -   Landing Page: Options for "Try Demo" or "Sign In" (Mobile only).

## Android Configuration
-   The `android/app/build.gradle` will be configured to match the Release configuration of the previous Android project.
-   Keystore references will be included (file provided later).

## Alternatives Considered
-   **Proxy for Web**: Rejected. Too much complexity for this phase.
-   **Disabling Web**: Rejected. Demo mode is desired on Web.

## Summary
This design creates a unified app with a clear separation between Guest (Demo) and User (Memverse) modes, while explicitly handling Web limitations by disabling the authenticated portion of the app on that platform.