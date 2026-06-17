# ================================================================
# FEATURE: CREATE USERS ARRAY API
# ================================================================
# Endpoint chain:
#   POST /api/register
#   POST /api/login
#   GET  /api/categorys
#   POST /api/book
#   GET /api/book/{id}
#   PUT /api/book/{id}
#
# Author  : TrungNguyen
# Version : 1.0.0
#
# Purpose:
#   Verify that a user can register, login, get a valid category,
#   create a new book, get it by id, and update its price successfully.
# ================================================================

  Feature: Create User Array

  Background:
    * def user = call read('classpath:features/auth/helpers/create-user.feature')
    * def auth = call read('classpath:features/auth/helpers/login-user.feature') { username: '#(user.username)', password: '#(user.password)' }
    * def token = auth.token
    * match token == "#notnull"
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

    Scenario Outline: Create Users
      * def username = generateUsername()
      * def email = generateEmail(username)
      * def payload = read('classpath:templates/auth/register-request.json')

      Given path 'api/user'
      And request payload
      When method POST
      Then status 200

      Examples:
        | username | email |
        |          |       |

