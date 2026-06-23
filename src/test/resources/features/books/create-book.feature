# ================================================================
# FEATURE: BOOK API - CREATE BOOK NEGATIVE TESTS
# ================================================================
# Endpoint:
#   POST /api/book
#
# Purpose:
#   Verify that the create book endpoint rejects unauthorized
#   requests (invalid or missing token).
#
# Test data:
#   Authentication, category IDs, book names, prices, and dates
#   are created or generated at runtime. No fixed resource
#   identifiers or account credentials are used.
# ================================================================
Feature: Create book negative validation

  Background:
    * url baseUrl
    * def bookName = generateBookName()
    * def bookPrice = generateBookPrice()
    * def releaseDate = generateDate()
    * def categoryResult = call read('classpath:features/categories/helpers/get-random-category.feature')
    * def categoryId = categoryResult.categoryId
    * def imgResult = call read('classpath:features/images/helpers/get-random-image.feature')
    * def imageId = imgResult.imageId
    * def payload = read('classpath:templates/book/book-request.json')

  @books @create-book @happy-path
  Scenario: Create a book with an invalid token
    * def auth = call read('classpath:features/auth/helpers/auth.feature')
    * header Authorization = 'Bearer ' + auth.token
    Given path 'api', 'book'
    And request payload
    When method post
    Then status 200
    And match response contains { message: 'Success', response: '#object' }
    And match response.response contains
      """
      {
        id: '#? _ > 0',
        name: '#(payload.name)',
        category_id: '#(payload.category_id)',
        price: '#(payload.price)',
        release_date: '#(payload.release_date)',
        status: '#(payload.status)',
        image: '#array'
      }
      """
    And match each response.response.image == { id: '#? _ > 0', path: '#regex public/images/[A-Za-z0-9]+\\.(jpg|jpeg|png|gif|webp)' }

  @books @create-book @negative
  Scenario: Create a book with an invalid token
    * def invalidToken = 'invalid_' + timestamp()
    * header Authorization = 'Bearer ' + invalidToken
    Given path 'api', 'book'
    And request payload
    When method post
    Then status 401

  @books @create-book @negative
  Scenario: Create a book without a token
    Given path 'api', 'book'
    And request payload
    When method post
    Then status 401
