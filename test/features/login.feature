Feature: Login
  As a user
  I want to log in
  So that I can access my account

  Scenario: Successful login
    Given the app starts
    When I enter "test" in the "Username" field
    And I enter "password" in the "Password" field
    And I tap "Login"
    Then I see "Home"
