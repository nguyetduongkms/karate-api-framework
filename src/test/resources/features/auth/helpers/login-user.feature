# ================================================================
# HELPER: LOGIN USER
# ================================================================
# Endpoint:
#   POST /api/login
#
# Purpose:
#   Get token
#
# Returns:
#   token
# ================================================================
@ignore
Feature: Get token helper
  Background:
    * url baseUrl

  Scenario: Get valid token
    Given path 'api', 'login'
    And request { username: '#(username)', password: '#(password)' }
    When method POST
    Then status 200
    And match response.token == '#regex \\d+\\|[A-Za-z0-9]{40,}'

    * def token = response.token