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
    * def auth = call read('classpath:features/auth/helpers/auth.feature')

  @smoke @users @happy-path
  Scenario Outline: Create users from array
    * header Authorization = 'Bearer ' + auth.token
    * def username = generateUsername()
    * def email = generateEmail(username)
    * def firstName = '<firstName>'
    * def lastName = '<lastName>'
    * def phone = '<phone>'
    * def userStatus = <userStatus>
    * def payload = read('classpath:templates/users/create-user-request.json')

    Given path 'api', 'users'
    And request payload
    When method POST
    Then status 200
    And match response contains { message: 'Success', response: '#array' }
    And match response.response contains
      """
      {
        username: '#(username)',
        firstName: '#(firstName)',
        lastName: '#(lastName)',
        email: '#(email)',
        password: '#(newUserPassword)',
        phone: '#(phone)',
        userStatus: '#(userStatus)'
      }
      """

    Examples:
      | read('classpath:testdata/valid-users.json') |
