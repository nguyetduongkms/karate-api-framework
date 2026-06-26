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
    * url baseUrl
    * def auth = callonce read('classpath:features/auth/helpers/login-user.feature')
    * def user = call read('classpath:features/auth/helpers/create-user.feature')

  @smoke @login @happy-path
  Scenario: Login with a newly registered user
    Given path 'api', 'login'
    And request { username: '#(user.username)', password: '#(user.password)' }
    When method POST
    Then status 200
    And match response.token == '#regex \\d+\\|[A-Za-z0-9]{40,}'

  @smoke @login @negative
  Scenario Outline: Login fails with invalid credentials
    Given path 'api', 'login'
    And request { username: '<username>', password: '<password>' }
    When method POST
    Then status 200
    And match response.message == 'Login failed'
    And match response.errors == '<expectedError>'

    Examples:
      | username               | password               | expectedError         |
      | #(user.username)_wrong | #(user.password)       | User name not found   |
      | #(user.username)       | #(user.password)_wrong | Password is incorrect |
      | #(user.username)_wrong | #(user.password)_wrong | User name not found   |

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
  Scenario Outline: Login when <field> is changed to new <field>
    * def updatedField = {}
    * karate.set('updatedField', field, user[field] + '_new')
    * def updatedUser = call read('classpath:features/users/helpers/update-user.feature') { token: '#(auth.token)', userId: '#(user.userId)', originalPayload: '#(user.payload)', updateFields: '#(updatedField)' }
    Given path 'api', 'login'
    And request { username: '#(user.username)', password: '#(user.password)' }
    When method POST
    Then status 200
    And match response.message == 'Login failed'
    And match response.errors == '<expectedError>'

    Examples:
      | field    | expectedError         |
      | username | User name not found   |
      | password | Password is incorrect |