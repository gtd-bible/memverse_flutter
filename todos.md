# TODOs for Memverse Flutter App

## High Priority

### Auth System Refactoring

- [ ] **Restore retrofit_generator dependency**
  - Re-enable in `pubspec.yaml` once the conflict with riverpod_generator is resolved
  - Run `flutter pub run build_runner build` to regenerate API code
  - Remove manual implementation of `AuthApi` class

- [ ] **Implement UserRepository pattern**
  - [ ] Create a proper `UserRepository` class to handle user data and state
  - [ ] Move auth functionality from direct API calls to repository pattern
  - [ ] Implement caching for user data
  - [ ] Add proper error handling and retry logic

- [ ] **Refactor Login and Signup Flows**
  - [ ] Move business logic from UI to repositories
  - [ ] Implement proper validation strategy
  - [ ] Add input sanitization
  - [ ] Improve error messages for better UX

## Medium Priority

### Test Improvements

- [ ] **Clean up test directory structure**
  - [ ] Move test utilities to proper location
  - [ ] Ensure all tests follow the same pattern
  - [ ] Add proper mocks for all dependencies

- [ ] **Improve test coverage**
  - [ ] Add more unit tests for AuthToken and AuthService
  - [ ] Add widget tests for all screens
  - [ ] Add integration tests for all user flows

### Audio Feature Implementation

- [ ] **Implement verse audio playback**
  - [ ] Set up audio player infrastructure
  - [ ] Add audio controls to verse detail screen
  - [ ] Support background playback
  - [ ] Handle interruptions (calls, other apps)

- [ ] **ASMR Bible Reading Experience**
  - [ ] Research best practices for ASMR audio in apps
  - [ ] Implement special audio mode with ASMR-style readings
  - [ ] Add background ambient sounds
  - [ ] Create visual indicators for ASMR mode

## Low Priority

- [ ] **Clean up debug code**
  - [ ] Remove all temporary logging
  - [ ] Clean up test-specific code in production
  - [ ] Review all TODOs and FIXMEs in the codebase

- [ ] **Improve documentation**
  - [ ] Add proper docstrings to all public methods
  - [ ] Create developer documentation
  - [ ] Add architecture diagrams

## Infrastructure

- [ ] **Set up CI/CD pipeline**
  - [ ] Automated testing on PR
  - [ ] Automated deployments
  - [ ] Version management

- [ ] **Analytics and Monitoring**
  - [ ] Review and optimize analytics events
  - [ ] Set up proper error boundaries
  - [ ] Implement crash reporting workflow