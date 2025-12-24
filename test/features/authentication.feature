Feature: User Authentication
    As a user
    I want to securely log in and out
    So that I can access my personalized scripture content

    Scenario: Successful login flow
        Given the app is running
        When I enter valid credentials
        And I tap "Login"
        Then I am logged in
        And I see my home screen

    Scenario: Invalid credentials are rejected
        Given the app is running
        When I enter invalid credentials
        And I tap "Login"
        Then I see an error message
        And I remain on the login screen

    Scenario: Guest mode for quick access
        Given the app is running
        When I tap "Continue as Guest"
        Then I can use the app without logging in

    Scenario: Stay logged in across sessions
        Given I logged in yesterday
        When I open the app today
        Then I am still logged in
        And I go straight to my content

    Scenario: Logout and security
        Given I am logged in
        When I tap "Logout"
        Then I am signed out
        And I see the login screen
        And my session is cleared
