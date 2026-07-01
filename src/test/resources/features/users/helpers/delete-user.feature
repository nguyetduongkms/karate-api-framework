# ================================================================
# HELPER: DELETE USER
# ================================================================
# Required input:
#   username
#
# The API accepts username as a query parameter:
#   DELETE /api/user?username={username}
# ================================================================
@ignore
Feature: Clean up user successfully
  Scenario: Clean up a user by username
    * url baseUrl
    * header Authorization = 'Bearer ' + authToken

    * def hasUser = typeof user !== 'undefined' && user != null
    * def hasPayload = hasUser && user.payload != null
    * def isInactiveUser = hasPayload && user.payload.userStatus == 0
    * if (isInactiveUser) karate.call('classpath:features/users/helpers/update-user.feature', { userId: user.userId, originalPayload: user.payload, updateFields: { userStatus: 1 } })

    * karate.log('[TEARDOWN][USER][START] username=' + username)

    Given path 'api', 'user'
    And param username = username
    When method DELETE
    * if (responseStatus != 200) karate.log('[TEARDOWN][USER][SKIPPED/FAILED]', username, responseStatus, response)
    * if (responseStatus == 200) karate.log('[TEARDOWN][USER][DELETED]', username)
