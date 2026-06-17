# ================================================================
# HELPER: GET BOOK BY ID API
# ================================================================
# Endpoint : GET /api/book/{id}
# Author   : TrungNguyen
# Version  : 1.0.0
#
# Purpose:
#  Get a book using using its id.
#
# Called by other features via:
#   * def getBookById = call read('classpath:features/book/helpers/get-book-by-id.feature') {bookId: '#(bookId)'}
#
# Required input from caller:
#   bookId       — valid book ID
#
# Returns:
#   getBookById.bookId
#   getBookById.bookName
#   getBookById.getBookByIdResponse
#
# @ignore prevents this helper from running as a standalone test.
# ================================================================

@ignore
Feature: Get Book By Id Helper

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  Scenario: Successfully Get Book with Valid Id
  # Validate required input from caller
    * match bookId == '#number'

    Given path 'api', 'book', bookId
    When method GET
    Then status 200

  # Validate top-level response
    And match response.message == 'Success'
    And match response.response == '#object'

  # Validate created book data
    And match response.response.id == '#notnull'
    And match response.response.name == '#string'
    And match response.response.category_id == '#number'
    And match response.response.price == '#number'
    And match response.response.release_date == '#string'
    And match response.response.status == '#number'
    And match response.response.image == '#array'
    And match each response.response.image == { id: '#number', path: '#string' }

  # Expose clean values to caller
    * def bookId = response.response.id
    * def bookName = response.response.name
    * def getBookByIdResponse = response