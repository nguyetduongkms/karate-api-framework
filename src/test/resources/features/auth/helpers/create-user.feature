# ================================================================
# HELPER: CREATE USER
# ================================================================
# Endpoint:
#   POST /api/register
#
# Purpose:
#   Register a unique user for tests that need fresh credentials.
#
# Returns:
#   username, password
# ================================================================
@ignore
Feature: Create user helper
  Scenario: Register a unique user
    * url baseUrl
    * def username = generateUsername()
    * def email = generateEmail(username)
    * def payload = read('classpath:templates/auth/register-request.json')
    * set payload.userStatus = karate.get('userStatus', 1)

    Given path 'api', 'register'
    And request payload
    When method POST
    Then status 200
    And match response.message == 'Success'
    And match response.response == '#object'
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
    * def username = response.response.username
    * def password = payload.password