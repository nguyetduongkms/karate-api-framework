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
    * def auth = callonce read('classpath:features/auth/helpers/login-user.feature')
    * header Authorization = 'Bearer ' + auth.token
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
    And match response.response == '#object'
    And match response.response.id == '#number? _ > 0'
    And match response.response.name == payload.name
    And match response.response.category_id == payload.category_id
    And match response.response.price == payload.price
    And match response.response.release_date == payload.release_date
    And match response.response.status == payload.status
    And match response.response.image == '#array'
    And match each response.response.image == { id: '#number? _ > 0', path: '#regex public/images/[A-Za-z0-9]+\\.(jpg|jpeg|png|gif|webp)' }

  @smoke @books @update-book @negative
  Scenario Outline: Update a book fail with an empty <field> field
    * set payload.<field> = ''
    Given path 'api', 'book', bookId
    And request payload
    When method PUT
    Then status 422
    And match response.message == '<expectedError>'
    And match response.errors.<field> == ["<expectedError>"]
    Examples:
      | field        | expectedError                       |
      | name         | The name field is required.         |
      | price        | The price field is required.        |
      | release_date | The release date field is required. |
      | status       | The status field is required.       |
      | category_id  | The category id field is required.  |

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
    * def secondBook = call read('classpath:features/books/helpers/create-book.feature') { token: '#(auth.token)' }
    * set payload.name = secondBook.payload.name
    Given path 'api', 'book', createdBook.bookId
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
