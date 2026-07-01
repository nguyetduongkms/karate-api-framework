# ================================================================
# FEATURE: USERS API
# ================================================================
# Endpoint:
#   POST /api/users
#
# Purpose:
#   Verify that an authenticated request can create users from
#   data-driven examples.
# ================================================================
Feature: Users API
  Background:
    * url baseUrl
    * header Authorization = 'Bearer ' + authToken
    * configure afterScenario =
      """
      function() {
        var payload = karate.get('payload') || [];

        for (var i = 0; i < payload.length; i++) {
          var username = payload[i].username;
          if (username) {
            karate.call('classpath:features/users/helpers/delete-user.feature', {
              username: username
            });
          }
        }
      }
      """

  @smoke @users @happy-path
  Scenario Outline: Create users from array
    * def username = generateUsername()
    * def email = generateEmail(username)
    * def data = { firstName: '<firstName>', lastName: '<lastName>', phone: '<phone>', userStatus: <userStatus> }
    * def payload = read('classpath:templates/users/create-user-request.json')
    Given path 'api', 'users'
    And request payload
    When method POST
    Then status 200
    And match response.message == 'Success'
    And match response.response == '#array'
    And match each response.response ==
      """
      {
        username: '#(username)',
        firstName: '#(data.firstName)',
        lastName: '#(data.lastName)',
        email: '#(email)',
        phone: '#(data.phone)',
        password: '#(newUserPassword)',
        userStatus: '#(data.userStatus)'
      }
      """
    Examples:
      | read('classpath:testdata/valid-users.json') |
