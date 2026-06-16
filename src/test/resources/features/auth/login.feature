# ================================================================
# FEATURE: LOGIN API
# ================================================================
# Endpoint : POST https://api.anhtester.com/api/login
# Author   : NguyetDuong
# Version  : 1.0.0
# ================================================================

Feature: Login and verify Access Token
  Purpose: Ensure the Login API returns a valid token for use with other APIs.
  Endpoint: POST /api/login

  Background:
    * def user = call read('classpath:features/auth/helpers/create-user.feature')
    * print user
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  # ================================================================
  # SCENARIO 1: SUCCESSFUL LOGIN (HAPPY PATH)
  # ================================================================
  # Credentials → DEMO_USERNAME / DEMO_PASSWORD env vars (see .env.example)
  @smoke @login @happy-path @test
  Scenario: Successful login with valid credentials
    Given path '/api/login'
    And request { username: '#(user.response.response.username)', password: '#(user.payload.password)' }
    When method POST
    Then status 200
    And match response.token == '#notnull'
    And assert response.token.length > 50
    * def accessToken = response.token
    * karate.set('globalToken', accessToken)
    * print '✅ Login successful!'
