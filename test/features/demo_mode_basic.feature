Feature: Demo Mode Basic Flows
    As a user trying out the app
    I want to use demo mode
    So that I can test scripture memorization features

    Scenario: Open demo mode and see the app
        Given the mocked app is running in demo mode
        Then I see "Scripture App (Demo)"
        And I see the add button

    Scenario: Add a verse to my list
        Given the mocked app is running in demo mode
        When I tap the add button
        And I enter "John 3:16" in the form
        And I tap "Submit"
        Then I see a success message

    Scenario: View my verses
        Given the mocked app is running in demo mode with verses
        Then I see "John 3:16"
        When I tap "John 3:16"
        Then I see the verse dialog

    Scenario: Delete a verse
        Given the mocked app is running in demo mode with verses
        When I swipe left on "John 3:16"
        And I tap "Delete"
        Then I no longer see "John 3:16"

    Scenario: Form validation works
        Given the mocked app is running in demo mode
        When I tap the add button
        And I tap "Submit" without entering anything
        Then I see "Please enter some text"
