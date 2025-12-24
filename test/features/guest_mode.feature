Feature: Guest Mode
    As a user
    I want to use the app without logging in
    So that I can try it out quickly

    Scenario: User continues as guest
        Given the app is running
        When I see the login screen
        And I tap "Continue as Guest"
        Then I see the home screen
