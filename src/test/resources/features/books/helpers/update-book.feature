# ================================================================
# HELPER: UPDATE BOOK API
# ================================================================
# Endpoint : PUT /api/book/{id}
# Author   : TrungNguyen
# Version  : 1.0.0
#
# Purpose:
#   Update a book using its id.
#
# Called by other features via:
#   * def updatedBook = call read('classpath:features/book/helpers/update-book.feature') { token: '#(token)', bookId: '#(bookId)', originalPayload: '#(createdBook.payload)', updateFields: '#(updateFields)' }
#
# Required input from caller:
#   bookId       — valid book ID
#
# Returns:
#   updatedBook.updatedPayload
#   updatedBook.updateBookResponse
#
# @ignore prevents this helper from running as a standalone test.
# ================================================================

@ignore
Feature: Update Book Helper

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  Scenario: Successfully update book with valid id

    # Validate required input from caller
    * match token == '#string'
    * match bookId == '#number'
    * match originalPayload == '#object'
    * match updateFields == '#object'

    # Prepare Authorization header
    * header Authorization = 'Bearer ' + token

    # Merge original payload with only the fields we want to update
    * def mergePayload =
    """
    function(original, updates) {
      var result = {};

      for (var key in original) {
        result[key] = original[key];
      }

      for (var key in updates) {
        result[key] = updates[key];
      }

      return result;
    }
    """

    * def payload = mergePayload(originalPayload, updateFields)

    Given path 'api', 'book', bookId
    And request payload
    When method PUT
    Then status 200

    # Validate top-level response
    And match response.message == 'Success'
    And match response.response == '#object'

    # Validate updated book data
    And match response.response.id == bookId
    And match response.response.name == payload.name
    And match response.response.category_id == payload.category_id
    And match response.response.price == payload.price
    And match response.response.release_date == payload.release_date
    And match response.response.status == payload.status
    And match response.response.image == '#array'
    And match each response.response.image == { id: '#number', path: '#string' }

    # Expose clean values to caller
    * def updateBookResponse = response
    * def updatedPayload = payload