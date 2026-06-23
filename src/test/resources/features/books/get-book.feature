# ================================================================
# FEATURE: BOOK API - GET BOOK NEGATIVE TESTS
# ================================================================
# Endpoint:
#   GET /api/book/{id}
#
# Purpose:
#   Verify that the get book endpoint correctly rejects requests
#   for a book id that does not exist.
#
# Test data:
#   The non-existent book id is generated at runtime using a
#   timestamp. No fixed resource identifiers are used.
# ================================================================
Feature: Get book negative validation

  Background:
    * url baseUrl
    * def auth = call read('classpath:features/auth/helpers/auth.feature')
    * def createdBook = call read('classpath:features/books/helpers/create-book.feature') {token: '#(auth.token)'}
    * def bookId = createdBook.bookId

  @books @get-book @happy-path
  Scenario: Get a book successfully
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

  @books @get-book @negative
  Scenario: Get a book that does not exist
    * def nonExistentBookId = timestamp()
    Given path 'api', 'book', nonExistentBookId
    When method get
    Then status 400
    And match response.message == 'Not found'
