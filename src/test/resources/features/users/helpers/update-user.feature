# ================================================================
# HELPER: UPDATE USER
# ================================================================
# Endpoint:
#   PUT /api/user/{id}
#
# Purpose:
#   Merge update fields into an existing user payload and update user
#
# Required input:
#   token, userId, originalPayload, updateFields
#
# Returns:
#   updatedPayload, updateUserResponse
# ================================================================
@ignore
Feature: Update user helper
  Background:
    * url baseUrl
    * header Authorization = 'Bearer ' + authToken

  Scenario: Update user by id
    * def payload = karate.merge(originalPayload, updateFields)
    Given path 'api', 'user', userId
    And request payload
    When method PUT
    Then status 200
    And match response.message == 'Success'
    And match response.response == '#object'
    And match response.response.id == '#number? _ > 0'
    And match response.response.username == payload.username
    And match response.response.firstName == payload.firstName
    And match response.response.lastName == payload.lastName
    And match response.response.email == payload.email
    And match response.response.phone == payload.phone
    And match response.response.userStatus == payload.userStatus
    * def updatedPayload = payload
    * def updateUserResponse = response
