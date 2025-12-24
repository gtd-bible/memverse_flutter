Feature: App Navigation
    As a user
    I want intuitive navigation
    So that I can easily move around the app

    Scenario: Protected content requires login
        Given I am not logged in
        When I try to view my verses
        Then I am redirected to login first

    Scenario: Navigate between app sections
        Given I am logged in
        When I tap between tabs
        Then I smoothly move between sections
        And I see my place in each section

    Scenario: Back button works intuitively
        Given I am deep in the app
        When I tap back
        Then I go to the previous screen
        And I don't lose my progress
