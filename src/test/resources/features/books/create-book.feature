# ================================================================
# FEATURE: BOOK API - CREATE BOOK TESTS
# ================================================================
# Endpoint:
#   POST /api/book
#
# Purpose:
#   Verify book creation behavior under authorized,
#   unauthorized, and missing token scenarios.
# ================================================================
Feature: Create book validation
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
  Scenario: Create a book successfully
    * def auth = call read('classpath:features/auth/helpers/login-user.feature')
    * header Authorization = 'Bearer ' + auth.token
    Given path 'api', 'book'
    And request payload
    When method post
    Then status 200
    And match response.message == 'Success'
    And match response.response == '#object'
    And match response.response contains
      """
      {
        id: '#number? _ > 0',
        name: '#(payload.name)',
        category_id: '#(payload.category_id)',
        price: '#(payload.price)',
        release_date: '#(payload.release_date)',
        status: '#(payload.status)',
        image: '#array'
      }
      """
    And match each response.response.image == { id: '#number? _ > 0 ', path: '#regex public/images/[A-Za-z0-9]+\\.(jpg|jpeg|png|gif|webp)' }

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
