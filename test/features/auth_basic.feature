Feature: Authentication Basic Flows
    As a user
    I want to log in
    So that I can access my content

    Scenario: Login with valid credentials
        Given the mocked app is running at login
        When I enter "test" in username
        And I enter "password" in password
        And I tap "Login"
        Then I see "Home Screen"

    Scenario: Login with invalid credentials
        Given the mocked app is running at login
        When I enter "wrong" in username
        And I enter "wrong" in password
        And I tap "Login"
        Then I see "Invalid username or password."

    Scenario: Guest mode access
        Given the mocked app is running at login
        When I tap "Continue as Guest"
        Then I see "Home Screen"
