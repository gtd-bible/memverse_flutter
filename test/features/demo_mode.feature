Feature: Demo Mode
  As a new user
  I want to try the app in demo mode
  So that I can see how it works

  Scenario: View demo home screen
    Given the app starts
    Then I see "Scripture App (Demo)"
    And I see "Add Scripture"
