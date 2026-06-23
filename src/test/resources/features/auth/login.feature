# ================================================================
# FEATURE: LOGIN API
# ================================================================
# Endpoint:
#   POST /api/login
#
# Purpose:
#   Verify that a newly registered user can login and receive a token.
# ================================================================
Feature: Login API
  Background:
    * def user = call read('classpath:features/auth/helpers/create-user.feature')
    * url baseUrl

  @smoke @login @happy-path
  Scenario: Login with a newly registered user
    Given path 'api', 'login'
    And request { username: '#(user.username)', password: '#(user.password)' }
    When method POST
    Then status 200
    And match response.token == '#regex \\d+\\|[A-Za-z0-9]{40,}'

  @smoke @login @negative
  Scenario: Login with incorrect username
    Given path 'api', 'login'
    And request { username: '#(user.username)_wrong', password: '#(user.password)' }
    When method POST
    Then status 200
    And match response.message == 'Login failed'
    And match response.errors == 'User name not found'

  @smoke @login @negative
  Scenario: Login with incorrect password
    Given path 'api', 'login'
    And request { username: '#(user.username)', password: '#(user.password)_wrong' }
    When method POST
    Then status 200
    And match response.message == 'Login failed'
    And match response.errors == 'Password is incorrect'

  @smoke @login @negative
  Scenario: Login with incorrect username and password
    Given path 'api', 'login'
    And request { username: '#(user.username)_wrong', password: '#(user.password)_wrong' }
    When method POST
    Then status 200
    And match response.message == 'Login failed'
    And match response.errors == 'User name not found'

  @smoke @login @negative
  Scenario: Login with userStatus = 0
    * def user = call read('classpath:features/auth/helpers/create-user.feature') { userStatus: 0 }
    Given path 'api', 'login'
    And request { username: '#(user.username)', password: '#(user.password)' }
    When method POST
    Then status 200
    And match response.message == 'Login failed'
    And match response.errors == 'User is InActive'

  @smoke @login @negative
  Scenario: Login when username is changed to new username
    * def newUsername = generateUsername()
    Given path 'api', 'login'
    And request { username: '#(newUsername)', password: '#(user.password)' }
    When method POST
    Then status 200
    And match response.message == 'Login failed'
    And match response.errors == 'User name not found'

  @smoke @login @negative
  Scenario: Login when password is changed to new password
    * def newPassword = user.password + '_new'
    Given path 'api', 'login'
    And request { username: '#(user.username)', password: '#(newPassword)' }
    When method POST
    Then status 200
    And match response.message == 'Login failed'
    And match response.errors == 'Password is incorrect'
