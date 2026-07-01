# ================================================================
# HELPER: DELETE BOOK
# ================================================================
# Required input:
#   bookId
# ================================================================
@ignore
Feature: Delete book helper

  Scenario: Delete book successfully
    * url baseUrl
    * header Authorization = 'Bearer ' + authToken
    * karate.log('[TEARDOWN][BOOK][START] id=' + bookId)

    Given path 'api', 'book', bookId
    When method DELETE
    * if (responseStatus != 200) karate.log('[TEARDOWN][BOOK][SKIPPED/FAILED]', bookId, responseStatus, response)
    * if (responseStatus == 200) karate.log('[TEARDOWN][BOOK][DELETED]', bookId)