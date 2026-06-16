# ================================================================
# HELPER: CREATE BOOK API
# ================================================================
# Endpoint : POST /api/book
# Author   : TrungNguyen
# Version  : 1.0.0
#
# Purpose:
#   Create a new book using a valid Authorization token.
#
# Called by other features via:
#   * def createdBook = call read('classpath:features/books/helpers/create-book.feature') { token: '#(token)', category_id: '#(category_id)' }
#
# Required input from caller:
#   token       — valid access token from Login API
#   category_id — valid category ID from Get Categories API
#
# Returns:
#   createdBook.bookId
#   createdBook.payload
#   createdBook.createBookResponse
#
# @ignore prevents this helper from running as a standalone test.
# ================================================================

@ignore
Feature: Create Book Helper

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  Scenario: Create a new book with valid data
  # Validate required input from caller
    * match token == '#string'
    * match categoryId == '#number'

  # Prepare Authorization header
    * header Authorization = 'Bearer ' + token

  # Prepare dynamic request data
    * def bookName = generateBookName()
    * def releaseDate = generateDate()
    * def bookPrice = generateBookPrice()
    * def payload = read('classpath:templates/book/book-request.json')

    Given path '/api/book'
    And request payload
    When method POST
    Then status 200

  # Validate top-level response
    And match response.message == 'Success'
    And match response.response == '#object'

  # Validate created book data
    And match response.response.id == '#notnull'
    And match response.response.name == payload.name
    And match response.response.category_id == payload.category_id
    And match response.response.price == payload.price
    And match response.response.release_date == payload.release_date
    And match response.response.status == payload.status
    And match response.response.image == '#array'

  # Expose clean values to caller
    * def bookId = response.response.id
    * def createBookResponse = response