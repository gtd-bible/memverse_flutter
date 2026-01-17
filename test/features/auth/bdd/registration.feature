Feature: User Registration
  As a new user
  I want to create an account
  So that I can use the app

  Scenario: User navigates to signup page from login screen
    Given I am on the login screen
    When I tap the create account link
    Then I should see the registration form

  Scenario: User submits signup form with empty fields
    Given I am on the signup screen
    When I submit the form without filling any fields
    Then I should see validation error messages
    And I should remain on the signup screen

  Scenario: User submits signup form with invalid email
    Given I am on the signup screen
    When I enter "invalid-email" in the email field
    And I enter "Password123" in the password field
    And I enter "Password123" in the confirm password field
    And I submit the form
    Then I should see an email validation error
    And I should remain on the signup screen

  Scenario: User submits signup form with mismatched passwords
    Given I am on the signup screen
    When I enter "valid@example.com" in the email field
    And I enter "Password123" in the password field
    And I enter "DifferentPassword" in the confirm password field
    And I submit the form
    Then I should see a password mismatch error
    And I should remain on the signup screen

  Scenario: User submits signup form with valid data
    Given I am on the signup screen
    When I enter "newuser@example.com" in the email field
    And I enter "SecurePassword123" in the password field
    And I enter "SecurePassword123" in the confirm password field
    And I submit the form
    Then I should see a loading indicator
    And signup analytics event should be triggered