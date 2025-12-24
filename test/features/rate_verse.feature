Feature: Rate Verse
    As a user
    I want to rate my memory of a verse
    So that the app can schedule it appropriately

    Scenario: User rates a verse with 5 stars
        Given the app is running
        And I am reviewing a verse
        When I tap the 5-star rating button
        Then I see a success message
        And the rating is saved
