# ================================================================
# HELPER: AUTHENTICATED USER
# ================================================================
# Endpoint chain:
#   POST /api/register
#   POST /api/login
#
# Purpose:
#   Create a dynamic user, login with that user, and expose auth data
#   for feature files that need an authenticated request.
#
# Returns:
#   token, userId
# ================================================================
@ignore
Feature: Auth helper
  Scenario: Register a dynamic user and login
    * def user = call read('classpath:features/auth/helpers/create-user.feature')
    * def login = call read('classpath:features/auth/helpers/login-user.feature') { username: '#(user.username)', password: '#(user.password)' }
    And match login.token == '#regex \\d+\\|[A-Za-z0-9]{40,}'

    * def token = login.token
    * def userId = user.userId
