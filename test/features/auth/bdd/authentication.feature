Feature: User Authentication
  As a user
  I want to log in to the app with my credentials
  So that I can access my personalized content

  Scenario: User logs in with valid credentials
    Given I am on the login screen
    When I enter valid credentials
    And I tap the login button
    Then I should be navigated to the dashboard

  Scenario: User attempts login with invalid credentials
    Given I am on the login screen
    When I enter invalid credentials
    And I tap the login button
    Then I should see an error message
    And I should remain on the login screen

  Scenario: User attempts login with network error
    Given I am on the login screen
    And I have no internet connection
    When I enter valid credentials
    And I tap the login button
    Then I should see a network error message
    And I should remain on the login screen
    And error should be logged to analytics

  Scenario: User successfully logs out
    Given I am logged in
    When I tap the logout button
    Then I should be navigated to the login screen
    And my session should be cleared