# ================================================================
# HELPER: LOGIN USER
# ================================================================
# Endpoint:
#   POST /api/login
#
# Purpose:
#   Login with a supplied username and password.
#
# Returns:
#   token, userId
# ================================================================
@ignore
Feature: Login user helper
  Background:
    * url baseUrl
    * def user = call read('classpath:features/auth/helpers/create-user.feature')

  Scenario: Login with valid credentials
    Given path 'api', 'login'
    And request { username: '#(user.username)', password: '#(user.password)' }
    When method POST
    Then status 200
    And match response.token == '#regex \\d+\\|[A-Za-z0-9]{40,}'

    * def token = response.token
    * def userId = user.userId