# ================================================================
# FEATURE: USERS API
# ================================================================
# Endpoint chain:
#   POST /api/register
#   POST /api/login
#   POST /api/users
#
# Purpose:
#   Verify that an authenticated request can create users from
#   data-driven examples.
# ================================================================
Feature: Users API
  Background:
    * url baseUrl
    * def auth = call read('classpath:features/auth/helpers/login-user.feature')
    * header Authorization = 'Bearer ' + auth.token

  @smoke @users @happy-path
  Scenario Outline: Create users from array
    * def username = generateUsername()
    * def email = generateEmail(username)
    * def data = { firstName: '<firstName>', lastName: '<lastName>', phone: '<phone>', userStatus: <userStatus> }
    * def payload = read('classpath:templates/users/create-user-request.json')
    Given path 'api', 'users'
    And request payload
    When method POST
    Then status 200
    And match response.message == 'Success'
    And match response.response == '#array'
    And match response.response contains
      """
      {
        username: '#(username)',
        firstName: '#(data.firstName)',
        lastName: '#(data.lastName)',
        email: '#(email)',
        password: '#(newUserPassword)',
        phone: '#(data.phone)',
        userStatus: '#(data.userStatus)'
      }
      """
    Examples:
      | read('classpath:testdata/valid-users.json') |
