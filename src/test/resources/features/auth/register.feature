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
    And match response.message == 'Success'
    And match response.response == '#object'
    And match response.response.id == '#number? _ > 0'
    And match response.response.username == payload.username
    And match response.response.firstName == payload.firstName
    And match response.response.lastName == payload.lastName
    And match response.response.email == payload.email
    And match response.response.phone == payload.phone
    And match response.response.userStatus == payload.userStatus

  @smoke @register @negative
  Scenario Outline: Register fails with empty <field> field
    * set payload.<field> = ''
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == '<expectedError>'
    Examples:
      | field      | expectedError                         |
      | username   | The username field is required.       |
      | email      | The email field is required.          |
      | password   | The password field format is invalid. |
      | firstName  | The first name field is required.     |
      | lastName   | The last name field is required.      |
      | userStatus | The user status field is required.    |
      | phone      | The phone field format is invalid.    |

  @smoke @register @negative
  Scenario Outline: Register with an existing <field>
    * set payload.<field> = existingUser.<field>
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == '<expectedError>'
    And match response.errors.<field> == ["<expectedError>"]
    Examples:
      | field    | expectedError                        |
      | username | The username has already been taken. |
      | email    | The email has already been taken.    |

  @smoke @register @negative
  Scenario: Register with an invalid email format
    * set payload.email = 'invalid-email'
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 422
    And match response.message == 'The email field must be a valid email address.'

  @smoke @register @negative
  Scenario: Register with an empty phone field
    * remove payload.phone
    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 500
    And match response.message == 'Server Error'