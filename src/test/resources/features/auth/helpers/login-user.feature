# ================================================================
# HELPER: LOGIN USER API
# ================================================================
# Endpoint : POST /api/login
# Author   : TrungNguyen
# Version  : 1.0.0
#
# Purpose:
#   Login with a valid username and password, then return the access token.
#
# Called by other features via:
#   * def loginResult = call read('classpath:features/auth/helpers/login-user.feature') { username: '#(user.username)', password: '#(user.password)' }
#
# Required input from caller:
#   username — valid registered username
#   password — valid password for that username
#
# Returns:
#   loginResult.token
#   loginResult.loginResponse
#
# @ignore prevents this helper from running as a standalone test.
# ================================================================

@ignore
Feature: Login User Helper

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  Scenario: Login with valid username and password
  # Validate required input from caller
    * match username == '#string'
    * match password == '#string'
    * assert username.length > 0
    * assert password.length > 0

    Given path '/api/login'
    And request
  """
  {
    "username": "#(username)",
    "password": "#(password)"
  }
  """
    When method POST
    Then status 200

  # Validate response
    And match response.token == '#string'
    And match response.token != ''

  # Expose clean values to caller
    * def token = response.token
    * def loginResponse = response