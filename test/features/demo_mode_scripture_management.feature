Feature: Demo Mode - Try Before You Sign Up
    As a new user exploring the app
    I want to try features without creating an account
    So that I can see if the app meets my needs

    Scenario: First time using demo mode
        Given I open demo mode for the first time
        Then I see 3 starter verses already loaded
        And I see "Scripture App (Demo)" in the header
        And I can immediately start practicing

    Scenario: Add my first custom verse
        Given I am in demo mode
        When I tap the add button
        And I type "Psalm 23:1"
        And I tap submit
        Then "Psalm 23:1" appears in my list
        And I can tap it to view the full text

    Scenario: Quick add multiple verses
        Given I am in demo mode
        When I add "John 3:16, Romans 8:28, Philippians 4:13"
        Then all 3 verses appear in my list
        And each verse is separately viewable

    Scenario: Form validation helps me
        Given I am adding a verse
        When I forget to fill in the reference
        And I tap submit
        Then I see a helpful validation message
        And I can fix my mistake
