Feature: User Onboarding and First Experience
    As a new user
    I want to quickly start using the app
    So that I can begin memorizing scripture immediately

    Scenario: First time user sees welcome and can login
        Given I open the app for the first time
        When I see the login screen
        Then I see "Login" heading
        And I see username and password fields
        And I see "Continue as Guest" option

    Scenario: Quick start with guest mode
        Given I open the app for the first time
        When I tap "Continue as Guest"
        Then I am taken to the home screen
        And I can start using the app immediately

    Scenario: Returning user is remembered
        Given I previously logged in successfully
        When I open the app
        Then I am automatically logged in
        And I see the home screen

    Scenario: User logs in with valid credentials
        Given I open the app
        When I enter my username and password
        And I tap "Login"
        Then I am authenticated
        And I see my personalized home screen
