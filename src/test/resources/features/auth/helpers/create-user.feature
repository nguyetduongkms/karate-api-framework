# ================================================================
# HELPER: CREATE USER (Reusable callable feature)
# ================================================================
# Called by other features via:
#   * def user = call read('classpath:features/auth/helpers/create-user.feature')
#
# Returns (available on the caller's result object):
#   user.username  — the registered username
#   user.password  — the password used during registration
#   user.email     — the registered email
#   user.userId    — the assigned user ID from the server
#
# @ignore prevents this from running as a standalone test.
# ================================================================
@ignore
Feature: Create a new user (reusable helper)

  Scenario: Register a unique user and expose credentials to the caller

    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

    # Generate a unique ID so the registered username never conflicts
    * def username = "user_" + Java.type('java.lang.System').currentTimeMillis()
    * def email = username + "@anhtester.com"
    * def payload  = read('classpath:templates/auth/register-request.json')

    Given path '/api/register'
    And   request payload
    When  method POST
    Then  status 200
    And match response.message == 'Success'
    And match response.response.username == payload.username
    And match response.response.firstName == payload.firstName
    And match response.response.lastName == payload.lastName
    And match response.response.email == payload.email
    And match response.response.phone == payload.phone
    And match response.response.userStatus == payload.userStatus
    And match response.response.id == '#notnull'

