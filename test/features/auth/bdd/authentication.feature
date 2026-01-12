@authentication @widget
Feature: User Authentication
  As a user
  I want to log in to the app with my credentials
  So that I can access my personalized content

  Background:
    Given the app is running

  Scenario: Successful login
    When I enter a valid username into the "loginUsernameField" text field
    And I enter a valid password into the "loginPasswordField" text field
    And I tap the "loginButton" button
    Then I see the "Dashboard" text

  Scenario: Failed login with wrong password
    When I enter a valid username into the "loginUsernameField" text field
    And I enter "wrong-password" into the "loginPasswordField" text field
    And I tap the "loginButton" button
    Then I see the "Invalid username or password" text
