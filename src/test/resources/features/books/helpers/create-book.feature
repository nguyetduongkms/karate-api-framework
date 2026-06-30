# ================================================================
# HELPER: CREATE BOOK
# ================================================================
# Endpoint:
#   POST /api/book
#
# Purpose:
#   Create a book using an authenticated token and category id.
#
# Required input:
#   token
#
# Returns:
#   bookId
# ================================================================
@ignore
Feature: Create book helper
  Background:
    * url baseUrl
    * header Authorization = 'Bearer ' + token

  Scenario: Create a book
    * def bookName = generateBookName()
    * def releaseDate = generateDate()
    * def bookPrice = generateBookPrice()
    * def categoryResult = call read('classpath:features/categories/helpers/get-random-category.feature')
    * def categoryId = categoryResult.categoryId
    * def imgResult = call read('classpath:features/images/helpers/get-random-image.feature')
    * def imageId = imgResult.imageId
    * def payload = read('classpath:templates/book/book-request.json')

    Given path 'api', 'book'
    And request payload
    When method POST
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
    * def bookId = response.response.id