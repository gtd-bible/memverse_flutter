# Implementation Plan - Navigation & Configuration Fixes

## Phase 1: Test Stabilization (Prerequisite)
- [ ] **Fix `login_page_test.dart`**:
    - [ ] Override `clientIdProvider` with a dummy value in `ProviderScope`.
    - [ ] Stub `canPop` on the `MockNavigator`.
- [ ] **Address Broken Tests**:
    - [ ] Investigate `app_router_test.dart`. If it refers to non-existent files (`auth_state.dart`), refactor it to use the current codebase or delete if obsolete.
    - [ ] Fix `widget_test.dart` and `navigation_test.dart` which reference `MyHelloWorldApp` (seems like a template artifact). Update them to pump `App()` or `LoginPage()`.
- [ ] **Run Tests**: Ensure `flutter test` passes (or at least compiles) before moving to features.

## Phase 2: Configuration Error Handling
- [ ] **Enhance `ConfigurationErrorWidget`**:
    - [ ] Update UI to display specific shell commands for missing variables.
    - [ ] Create a helper to generate the copy-pasteable text.
- [ ] **Verify**: Manually verify by temporarily removing env vars in `main.dart` or a test.

## Phase 3: Persistence & Preferences
- [ ] **Create `PreferencesRepository`**:
    - [ ] Interface for `flutter_secure_storage`.
    - [ ] Keys: `is_first_launch`, `preferred_tab`, `alpha_tester`, `beta_tester`.
    - [ ] Methods: `get/setFirstLaunch`, `get/setPreferredTab`.
- [ ] **Integrate with `SettingsScreen`**:
    - [ ] Add "Default Tab" dropdown.
    - [ ] **Alpha/Beta Switches**: Ensure they update *both* the local persistence (so the UI switch remains toggled) AND the Firebase Analytics user properties (as currently implemented).

## Phase 4: Navigation Logic
- [ ] **Update `SignedInNavScaffold`**:
    - [ ] Read `PreferencesRepository` on init.
    - [ ] Logic:
        - If `preferred_tab` exists -> Use it.
        - Else if `first_launch` -> Index 0 (Home), set `first_launch = false`.
        - Else -> Index 2 (Ref Quiz).
- [ ] **Home Tab Message**:
    - [ ] Add an info card/banner on Home Tab: "Tip: You can set your default start tab in Settings."

## Phase 5: Integration Testing (Navigation)
- [ ] **Create `navigation_flow_test.dart`**:
    - [ ] **Real Navigation Test**: Use `pumpWidget` with the real `App` or `SignedInNavScaffold`.
    - [ ] **Scenario 1**: Tap "Ref Quiz" tab -> Verify "Ref Quiz" screen content appears.
    - [ ] **Scenario 2**: Tap "Verse Quiz" tab -> Verify "Verse Quiz" screen content appears.
    - [ ] **Scenario 3**: Verify initial tab logic (mock the `PreferencesRepository` for this test to simulate first vs subsequent launch).

## Phase 6: Final Polish
- [ ] **Cleanup**: Run `dart fix`, `dart format`.
- [ ] **Docs**: Update `README.md` if env var instructions need clarification.
- [ ] **Verification**: Final full test run.

## Journal
- ...