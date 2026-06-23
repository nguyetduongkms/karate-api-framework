# ================================================================
# FEATURE: REGISTER API
# ================================================================
# Endpoint:
#   POST /api/register
#
# Purpose:
#   Verify that the API can register a new user with dynamic data
#   and verify that registration rejects missing, duplicate, and
#   invalid user data with exact message and response.
# ================================================================
Feature: Register API
  Background:
    * url baseUrl
    * def username = generateUsername()
    * def email = generateEmail(username)
    * def payload = read('classpath:templates/auth/register-request.json')

  @smoke @register @happy-path
  Scenario: Register a dynamic user successfully
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 200
    And match response contains { message: 'Success', response: '#object' }
    And match response.response contains
      """
      {
        id: '#number? _ > 0',
        username: '#(payload.username)',
        firstName: '#(payload.firstName)',
        lastName: '#(payload.lastName)',
        email: '#(payload.email)',
        phone: '#(payload.phone)',
        userStatus: '#(payload.userStatus)'
      }
      """

  @smoke @register @negative
  Scenario: Register with an empty username
    * set payload.username = ''
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == 'The username field is required.'

  @smoke @register @negative
  Scenario: Register with an empty email
    * set payload.email = ''
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == 'The email field is required.'

  @smoke @register @negative
  Scenario: Register with an empty password
    * set payload.password = ''
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == 'The password field format is invalid.'

  @smoke @register @negative
  Scenario: Register with an existing username
    * set payload.username = existingUser.username
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == 'The username has already been taken.'

  @smoke @register @negative
  Scenario: Register with an empty first name
    * set payload.firstName = ''
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == 'The first name field is required.'

  @smoke @register @negative
  Scenario: Register with an empty last name
    * set payload.lastName = ''
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == 'The last name field is required.'

  @smoke @register @negative
  Scenario: Register with an empty user status
    * set payload.userStatus = ''
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == 'The user status field is required.'

  @smoke @register @negative
  Scenario: Register with an existing email
    * set payload.email = existingUser.email
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == 'The email has already been taken.'

  @smoke @register @negative
  Scenario: Register with an invalid email format
    * set payload.email = 'invalid-email'
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == 'The email field must be a valid email address.'

  @smoke @register @negative
  Scenario: Register with a null phone
    * set payload.phone = null
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == 'The phone field format is invalid.'

  @smoke @register @negative
  Scenario: Register with an empty phone
    * remove payload.phone
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 500
    And match response.message == 'Server Error'