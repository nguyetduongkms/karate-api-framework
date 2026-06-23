# ================================================================
# HELPER: LOGIN USER
# ================================================================
# Endpoint:
#   POST /api/login
#
# Purpose:
#   Login with a supplied username and password.
#
# Required input:
#   username, password
#
# Returns:
#   token, loginResponse
# ================================================================
@ignore
Feature: Login user helper

  Background:
    * url baseUrl

  Scenario: Login with valid credentials
    Given path 'api', 'login'
    And request { username: '#(username)', password: '#(password)' }
    When method post
    Then status 200
    And match response.token == '#regex \\d+\\|[A-Za-z0-9]{40,}'

    * def token = response.token