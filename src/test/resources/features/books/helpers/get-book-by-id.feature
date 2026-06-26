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
#   getBookByIdResponse
# ================================================================
@ignore
Feature: Get book by id helper
  Background:
    * url baseUrl

  Scenario: Get a book by id
    Given path 'api', 'book', bookId
    When method GET
    Then status 200
    And match response.message == 'Success'
    And match response.response == '#object'
    And match response.response.id == bookId
    And match response.response.name == '#string'
    And match response.response.category_id == '#number? _ > 0'
    And match response.response.price == '#number? _ > 0'
    And match response.response.release_date == '#regex [0-9]{4}-[0-9]{2}-[0-9]{2}'
    And match response.response.status == '#number'
    And match response.response.image == '#array'
    And match each response.response.image == { id: '#number? _ > 0', path: '#regex public/images/[A-Za-z0-9]+\\.(jpg|jpeg|png|gif|webp)' }
    * def getBookByIdResponse = response