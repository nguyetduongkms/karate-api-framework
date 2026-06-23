# ================================================================
# FEATURE: BOOK API - UPDATE BOOK TESTS
# ================================================================
# Endpoint:
#   PUT /api/book/{id}
#
# Purpose:
#   Verify book updates under successful, missing fields,
#   duplicate values, and invalid image ID conditions.
# ================================================================
Feature: Update book validation
  Background:
    * url baseUrl
    * def auth = call read('classpath:features/auth/helpers/auth.feature')
    * header Authorization = 'Bearer ' + auth.token
    * def categoryResult = call read('classpath:features/categories/helpers/get-random-category.feature')
    * def createdBook = call read('classpath:features/books/helpers/create-book.feature') { token: '#(auth.token)' }
    * def payload = createdBook.payload
    * def bookId = createdBook.bookId

  @books @update-book @happy-path
  Scenario: Update a book successfully
    Given path 'api', 'book', bookId
    And request payload
    When method PUT
    Then status 200
    And match response.message == 'Success'
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
    And match each response.response.image == { id: '#number? _ > 0 ', path: '#regex public/images/[A-Za-z0-9]+\\.(jpg|jpeg|png|gif|webp)' }

  @books @update-book @negative
  Scenario: Update a book with an empty name
    * set payload.name = ''
    Given path 'api', 'book', bookId
    And request payload
    When method PUT
    Then status 422
    And match response.message == 'The name field is required.'

  @books @update-book @negative
  Scenario: Update a book with an empty price
    * set payload.price = ''
    Given path 'api', 'book', bookId
    And request payload
    When method PUT
    Then status 422
    And match response.message == 'The price field is required.'

  @books @update-book @negative
  Scenario: Update a book with an empty release date
    * set payload.release_date = ''
    Given path 'api', 'book', bookId
    And request payload
    When method PUT
    Then status 422
    And match response.message == 'The release date field is required.'

  @books @update-book @negative
  Scenario: Update a book with an empty status
    * set payload.status = ''
    Given path 'api', 'book', bookId
    And request payload
    When method PUT
    Then status 422
    And match response.message == 'The status field is required.'

  @books @update-book @negative
  Scenario: Update a book with an empty category id
    * set payload.category_id = ''
    Given path 'api', 'book', bookId
    And request payload
    When method PUT
    Then status 422
    And match response.message == 'The category id field is required.'

  @books @update-book @negative
  Scenario: Update a book with an empty image id
    * set payload.image_ids = []
    Given path 'api', 'book', bookId
    And request payload
    When method PUT
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
    When method PUT
    Then status 422
    And match response.message == 'The name has already been taken.'

  @books @update-book @negative
  Scenario: Update a book with an image id that does not exist
    * def nonExistentImageId = timestamp()
    * set payload.image_ids = [nonExistentImageId]
    Given path 'api', 'book', bookId
    And request payload
    When method PUT
    Then status 422
    And match response.message == 'The selected image_ids.0 is invalid.'
