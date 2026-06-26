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
    * header Authorization = 'Bearer ' + token
    * def payload = karate.merge(originalPayload, updateFields)
    Given path 'api', 'book', bookId
    And request payload
    When method PUT
    Then status 200
    And match response.message == 'Success'
    And match response.response == '#object'
    And match response.response.id == '#number? _ > 0'
    And match response.response.name == payload.name
    And match response.response.category_id == payload.category_id
    And match response.response.price == payload.price
    And match response.response.release_date == payload.release_date
    And match response.response.status == payload.status
    And match response.response.image == '#array'
    And match each response.response.image == { id: '#number? _ > 0', path: '#regex public/images/[A-Za-z0-9]+\\.(jpg|jpeg|png|gif|webp)' }
    * def updatedPayload = payload
    * def updateBookResponse = response
