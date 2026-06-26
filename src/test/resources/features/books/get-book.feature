# ================================================================
# FEATURE: BOOK API - GET BOOK TESTS
# ================================================================
# Endpoint:
#   GET /api/book/{id}
#
# Purpose:
#   Verify book retrieval behavior for both existing
#   and non-existent book IDs.
# ================================================================
Feature: Get book validation
  Background:
    * url baseUrl
    * def auth = callonce read('classpath:features/auth/helpers/login-user.feature')
    * def createdBook = call read('classpath:features/books/helpers/create-book.feature') {token: '#(auth.token)'}
    * def bookId = createdBook.bookId

  @books @get-book @happy-path
  Scenario: Get a book successfully
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

  @books @get-book @negative
  Scenario: Get a book that does not exist
    * def nonExistentBookId = timestamp()
    Given path 'api', 'book', nonExistentBookId
    When method GET
    Then status 400
    And match response.message == 'Not found'
