# ================================================================
# HELPER: GET BOOK BY ID
# ================================================================
# Endpoint:
#   GET /api/book/{id}
#
# Purpose:
#   Retrieve a book by id and validate its response schema.
#
# Required input:
#   bookId
#
# Returns:
#   bookName, getBookByIdResponse
# ================================================================
@ignore
Feature: Get book by id helper

  Background:
    * url baseUrl

  Scenario: Get a book by id
    * match bookId == '#number'

    Given path 'api', 'book', bookId
    When method get
    Then status 200
    And match response contains { message: 'Success', response: '#object' }
    And match response.response contains
      """
      {
        id: '#(bookId)',
        name: '#string',
        category_id: '#number',
        price: '#number',
        release_date: '#string',
        status: '#number',
        image: '#array'
      }
      """
    And match each response.response.image == { id: '#? _ > 0', path: '#regex public/images/[A-Za-z0-9]+\\.(jpg|jpeg|png|gif|webp)' }

    * def bookName = response.response.name
    * def getBookByIdResponse = response
