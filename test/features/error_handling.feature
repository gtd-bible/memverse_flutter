Feature: Error Handling and Recovery
    As a user
    I want clear feedback when things go wrong
    So that I can understand and fix issues

    Background:
        Given I am using the app

    Scenario: Invalid scripture reference
        Given I am adding a new verse
        When I enter "Invalid 99:99" as the reference
        And I submit the form
        Then I see an error message
        And the verse is not added
        And I can try again with a different reference

    Scenario: Empty form validation
        Given I am adding a new verse
        When I tap submit without entering anything
        Then I see "Please enter some text" on the reference field
        And the form does not submit

    Scenario: Network error during scripture fetch
        Given the network is unavailable
        When I try to add "John 3:16"
        Then I see a helpful error message
        And I can retry when network returns

    Scenario: Invalid login credentials
        Given I am on the login screen
        When I enter wrong credentials
        And I tap "Login"
        Then I see "Invalid username or password."
        And I can try again
        And my previous username is still filled in

    Scenario: Malformed verse reference
        Given I am adding a verse
        When I enter "This is not a reference" 
        And I submit
        Then I see an appropriate error
        And the form stays open for correction

    Scenario: Graceful degradation without network
        Given I am offline
        When I try to add a new verse
        Then I see "Network unavailable" message
        But I can still view my existing verses
        And I can still practice with blur

    Scenario: Error recovery after failed deletion
        Given deletion fails due to database error
        When I try to delete a verse
        Then I see an error message
        And the verse remains in the list
        And I can try again
