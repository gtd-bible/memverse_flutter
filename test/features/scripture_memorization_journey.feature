Feature: Scripture Memorization Journey
    As a user wanting to memorize scripture
    I want to add verses, practice them, and track progress
    So that I can effectively memorize God's word

    Background:
        Given I am using the app in demo mode

    Scenario: Add my first scripture verse
        When I tap the add button
        And I enter "John 3:16" as the reference
        And I enter "My First Verses" as the collection
        And I submit the form
        Then the verse is fetched from the API
        And "John 3:16" appears in my list
        And I see the verse text "For God so loved the world"

    Scenario: Practice memorization with blur
        Given I have "John 3:16" in my collection
        When I tap on the verse
        And I see the full verse text
        And I tap "Blur" to start practicing
        Then some words become hidden
        When I tap "Blur more"
        Then more words are hidden
        And I can test my memory

    Scenario: Reduce blur to check my work
        Given I am practicing a verse with blur
        When I tap "Blur less"
        Then fewer words are hidden
        And I can see if I remembered correctly

    Scenario: Organize verses into collections
        Given I have added several verses
        When I tap the collections menu
        Then I see all my collections
        When I tap "Create New Collection"
        And I name it "Comfort Verses"
        Then I can add verses to that collection

    Scenario: Share a meaningful verse
        Given I have "Philippians 4:13" in my list
        When I tap on the verse
        And I tap the share button
        Then the share dialog opens
        And the verse and reference are ready to share

    Scenario: Remove a verse I no longer need
        Given I have verses in my collection
        When I swipe left on a verse
        And I tap "Delete"
        Then the verse is removed from my collection

    Scenario: Batch add multiple verses
        When I tap the add button
        And I enter "Romans 8:28, Proverbs 3:5-6, Matthew 6:33"
        And I submit the form
        Then all three verses are added
        And I see 3 new verses in my list

    Scenario: Quick practice session
        Given I have 10 verses in my collection
        When I open any verse
        And I practice with blur
        And I move to the next verse
        Then I can practice multiple verses in succession
