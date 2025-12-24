Feature: Collection Management
    As a user organizing my scripture
    I want to manage collections and lists
    So that I can group verses by topic or purpose

    Background:
        Given I am in demo mode
        And I have verses in multiple collections

    Scenario: View all my collections
        When I tap the collections button
        Then I see a list of all my collections
        And each shows its name
        And the current collection is highlighted

    Scenario: Switch between collections
        Given I am viewing "Daily Verses"
        When I tap the collections button
        And I select "Memory Work"
        Then I see verses from "Memory Work"
        And the screen title shows "Memory Work"

    Scenario: Rename a collection
        Given I am viewing "My List"
        When I tap the edit button next to the collection name
        And I enter "Favorite Psalms" as the new name
        And I confirm
        Then the collection is renamed to "Favorite Psalms"
        And all verses remain in the collection

    Scenario: Collection persists across app restarts
        Given I create a collection called "Wedding Verses"
        And I add 5 verses to it
        When I close and reopen the app
        Then "Wedding Verses" is still there
        And all 5 verses are intact

    Scenario: Add verse to different collection
        Given I am viewing "Daily Verses"
        When I add a new verse
        And I specify "Special Collection" as the list
        Then the verse is added to "Special Collection"
        But I remain viewing "Daily Verses"

    Scenario: Empty collection shows helpful message
        Given I create a new empty collection
        When I view that collection
        Then I see "No verses in this list."
        And I see the add button to start adding verses

    Scenario: Pull to refresh updates verse list
        Given I am viewing a collection
        When I pull down on the list
        Then the list refreshes
        And any changes are loaded
