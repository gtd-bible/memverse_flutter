Feature: Authentication Analytics & Crashlytics
  As a developer
  I want to track authentication events and errors
  So that I can monitor user login patterns and troubleshoot issues

  Background:
    Given the app is installed and launched
    And analytics collection is enabled
    And crashlytics reporting is enabled

  Scenario: Successful login with valid credentials
    When the user enters a valid username and password
    And taps the login button
    Then a "login_attempt" event should be logged with username length parameter
    And a "login" standard Firebase event should be logged
    And a "login_success" event should be logged with user_id, token_type, and authenticated parameters
    And the user should be navigated to the dashboard screen
    And the user_id should be set in both Analytics and Crashlytics

  Scenario: Failed login with invalid credentials
    When the user enters an invalid username and password
    And taps the login button
    Then a "login_attempt" event should be logged with username length parameter
    And an "auth_error" event should be logged with error details
    And the error should be recorded in Crashlytics with stack trace
    And a non-fatal error should be logged with additional data
    And an appropriate error message should be displayed to the user

  Scenario: Failed login with empty token response
    When the server returns an empty token response
    Then a "login_empty_token" event should be logged
    And the error should be recorded in Talker
    And an appropriate error message should be displayed to the user

  Scenario: Network error during login
    When a network error occurs during login
    Then the error should be recorded in Crashlytics with stack trace
    And an "auth_error" event should be logged with error details
    And a non-fatal error should be recorded with reason "Login failure"
    And relevant diagnostic information should be attached to the error
    And an appropriate error message should be displayed to the user

  Scenario: Successful logout
    Given the user is logged in
    When the user logs out
    Then a "user_logout" event should be logged with user_id and session_active parameters
    And a "logout" event should be logged
    And the user should be navigated to the login screen

  Scenario: Error during logout
    Given the user is logged in
    When an error occurs during logout
    Then the error should be recorded in Crashlytics with stack trace
    And an "auth_error" event should be logged with error details
    And a non-fatal error should be recorded with reason "Logout failure"
    And an appropriate error message should be displayed to the user