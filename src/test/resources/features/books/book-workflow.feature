# ================================================================
# FEATURE: BOOK WORKFLOW API
# ================================================================
# Endpoint chain:
#   POST /api/register
#   POST /api/login
#   GET  /api/categorys
#   POST /api/book
#   GET  /api/book/{id}
#   PUT  /api/book/{id}
#
# Purpose:
#   Verify that an authenticated user can create a book, retrieve it,
#   and update its price.
# ================================================================
Feature: Book workflow
  Background:
    * configure afterScenario =
      """
      function() {
        var updatedBook = karate.get('updatedBook');
        if (updatedBook && updatedBook.bookId) {
          karate.call('classpath:features/books/helpers/delete-book.feature', {
            bookId: updatedBook.bookId
          });
        }
      }
      """

  @smoke @books @happy-path
  Scenario: Create, read, and update a book as an authenticated user
    # Pick an existing category for the new book.
    * def categoryResult = call read('classpath:features/categories/helpers/get-random-category.feature')
    * def categoryId = categoryResult.categoryId

    # Create the book
    * def createdBook = call read('classpath:features/books/helpers/create-book.feature') { categoryId: '#(categoryId)' }
    * def bookId = createdBook.bookId

    # Get book by id
    * def foundBook = call read('classpath:features/books/helpers/get-book-by-id.feature') { bookId: '#(bookId)' }
    * match foundBook.getBookByIdResponse.response.id == bookId

    # Update price for the founded book
    * def bookPrice = generateBookPrice()
    * def updateFields = { price: '#(bookPrice)' }
    * def updatedBook = call read('classpath:features/books/helpers/update-book.feature') { bookId: '#(bookId)', originalPayload: '#(createdBook.payload)', updateFields: '#(updateFields)' }
    * match updatedBook.updateBookResponse.response.price == bookPrice
