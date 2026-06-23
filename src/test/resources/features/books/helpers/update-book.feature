# ================================================================
# HELPER: UPDATE BOOK
# ================================================================
# Endpoint:
#   PUT /api/book/{id}
#
# Purpose:
#   Merge update fields into an existing book payload and submit it.
#
# Required input:
#   token, bookId, originalPayload, updateFields
#
# Returns:
#   updatedPayload, updateBookResponse
# ================================================================
@ignore
Feature: Update book helper

  Background:
    * url baseUrl

  Scenario: Update a book by id
    * match token == '#string'
    * match bookId == '#number'
    * match originalPayload == '#object'
    * match updateFields == '#object'

    * header Authorization = 'Bearer ' + token
    * def mergePayload =
      """
      function(original, updates) {
        var result = {};
        for (var key in original) result[key] = original[key];
        for (var key in updates) result[key] = updates[key];
        return result;
      }
      """
    * def payload = mergePayload(originalPayload, updateFields)

    Given path 'api', 'book', bookId
    And request payload
    When method put
    Then status 200
    And match response contains { message: 'Success', response: '#object' }
    And match response.response contains
      """
      {
        id: '#(bookId)',
        name: '#(payload.name)',
        category_id: '#(payload.category_id)',
        price: '#(payload.price)',
        release_date: '#(payload.release_date)',
        status: '#(payload.status)',
        image: '#array'
      }
      """
    And match each response.response.image == { id: '#? _ > 0', path: '#regex public/images/[A-Za-z0-9]+\\.(jpg|jpeg|png|gif|webp)' }

    * def updatedPayload = payload
    * def updateBookResponse = response
