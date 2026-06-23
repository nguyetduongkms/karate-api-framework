# ================================================================
# FEATURE: BOOK API - UPDATE BOOK NEGATIVE TESTS
# ================================================================
# Endpoint:
#   PUT /api/book/{id}
#
# Purpose:
#   Verify that the update book endpoint rejects requests with
#   missing required fields, duplicate names, and invalid image
#   ids.
#
# Test data:
#   Authentication, category IDs, book ids, image ids, names,
#   prices, and dates are created or generated at runtime. No
#   fixed resource identifiers or account credentials are used.
# ================================================================
Feature: Update book negative validation

  Background:
    * url baseUrl
    * def auth = call read('classpath:features/auth/helpers/auth.feature')
    * header Authorization = 'Bearer ' + auth.token
    * def categoryResult = call read('classpath:features/categories/helpers/get-random-category.feature')
    * def createdBook = call read('classpath:features/books/helpers/create-book.feature') { token: '#(auth.token)' }
    * def payload = createdBook.payload

  @books @update-book @happy-path
  Scenario: Update a book with an empty name
    Given path 'api', 'book', createdBook.bookId
    And request payload
    When method put
    Then status 200
    And match response.message == 'Success'
    And match response.response contains
      """
      {
        id: '#(createdBook.bookId)',
        name: '#(payload.name)',
        category_id: '#(payload.category_id)',
        price: '#(payload.price)',
        release_date: '#(payload.release_date)',
        status: '#(payload.status)',
        image: '#array'
      }
      """
    And match each response.response.image == { id: '#? _ > 0', path: '#regex public/images/[A-Za-z0-9]+\\.(jpg|jpeg|png|gif|webp)' }

  @books @update-book @negative
  Scenario: Update a book with an empty name
    * set payload.name = ''
    Given path 'api', 'book', createdBook.bookId
    And request payload
    When method put
    Then status 422
    And match response.message == 'The name field is required.'

  @books @update-book @negative
  Scenario: Update a book with an empty price
    * set payload.price = ''
    Given path 'api', 'book', createdBook.bookId
    And request payload
    When method put
    Then status 422
    And match response.message == 'The price field is required.'

  @books @update-book @negative
  Scenario: Update a book with an empty release date
    * set payload.release_date = ''
    Given path 'api', 'book', createdBook.bookId
    And request payload
    When method put
    Then status 422
    And match response.message == 'The release date field is required.'

  @books @update-book @negative
  Scenario: Update a book with an empty status
    * set payload.status = ''
    Given path 'api', 'book', createdBook.bookId
    And request payload
    When method put
    Then status 422
    And match response.message == 'The status field is required.'

  @books @update-book @negative
  Scenario: Update a book with an empty category id
    * set payload.category_id = ''
    Given path 'api', 'book', createdBook.bookId
    And request payload
    When method put
    Then status 422
    And match response.message == 'The category id field is required.'

  @books @update-book @negative
  Scenario: Update a book with an empty image id
    * set payload.image_ids = []
    Given path 'api', 'book', createdBook.bookId
    And request payload
    When method put
    Then status 422
    And match response.message == 'The image ids field is required.'

  @books @update-book @negative
  Scenario: Update a book with an existing name
    * def firstBook = call read('classpath:features/books/helpers/create-book.feature') { token: '#(auth.token)', categoryId: '#(categoryResult.categoryId)' }
    * def secondBook = call read('classpath:features/books/helpers/create-book.feature') { token: '#(auth.token)', categoryId: '#(categoryResult.categoryId)' }
    * def payload = firstBook.payload
    * set payload.name = secondBook.payload.name
    Given path 'api', 'book', firstBook.bookId
    And request payload
    When method put
    Then status 422
    And match response.message == 'The name has already been taken.'

  @books @update-book @negative
  Scenario: Update a book with an image id that does not exist
    * def nonExistentImageId = timestamp()
    * def payload = createdBook.payload
    * set payload.image_ids = [nonExistentImageId]
    Given path 'api', 'book', createdBook.bookId
    And request payload
    When method put
    Then status 422
    And match response.message == 'The selected image_ids.0 is invalid.'
