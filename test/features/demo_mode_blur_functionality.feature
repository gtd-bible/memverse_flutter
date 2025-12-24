Feature: Progressive Memory Practice with Blur
    As someone memorizing scripture
    I want to gradually hide words
    So that I can test and strengthen my memory

    Background:
        Given I have a verse open in demo mode

    Scenario: Start practicing with blur
        When I tap "Blur"
        Then some words become hidden
        And I can try to recall the hidden words

    Scenario: Make it harder by hiding more
        Given I have started blurring
        When I tap "Blur more"
        Then even more words disappear
        And I must rely more on memory

    Scenario: Check my work by revealing words
        Given many words are hidden
        When I tap "Blur less"
        Then I see more of the text
        And I can verify what I remembered

    Scenario: Full memorization challenge
        When I keep tapping "Blur more"
        Then eventually most words are hidden
        And I can test complete memorization
