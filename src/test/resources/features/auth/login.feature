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
    * def user = callonce read('classpath:features/auth/helpers/create-user.feature')
    * configure afterFeature =
      """
      function() {
        var user = karate.get('user');
        var cleanupUsername = karate.get('cleanupUsername') || user.username;

        karate.call('classpath:features/users/helpers/delete-user.feature', {
          user: user,
          username: cleanupUsername
        });
      }
      """

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
    * def inActiveUser = call read('classpath:features/auth/helpers/create-user.feature') { userStatus: 0 }
    Given path 'api', 'login'
    And request { username: '#(inActiveUser.username)', password: '#(inActiveUser.password)' }
    When method POST
    Then status 200
    And match response.message == 'Login failed'
    And match response.errors == 'User is InActive'
    * call read('classpath:features/users/helpers/delete-user.feature') { username: '#(inActiveUser.username)' }

  @smoke @login @negative
  Scenario Outline: Login fails with old credentials after <field> is updated
    * def changedUser = call read('classpath:features/auth/helpers/create-user.feature')
    * def updatedField = {}
    * karate.set('updatedField', field, changedUser[field] + '_new')
    * def updatedUser = call read('classpath:features/users/helpers/update-user.feature') { userId: '#(changedUser.userId)', originalPayload: '#(changedUser.payload)', updateFields: '#(updatedField)' }
    Given path 'api', 'login'
    And request { username: '#(changedUser.username)', password: '#(changedUser.password)' }
    When method POST
    Then status 200
    And match response.message == 'Login failed'
    And match response.errors == '<expectedError>'
    * call read('classpath:features/users/helpers/delete-user.feature') { username: '#(updatedUser.payload.username)' }

    Examples:
      | field    | expectedError         |
      | username | User name not found   |
      | password | Password is incorrect |