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

  @smoke @books @happy-path
  Scenario: Create, read, and update a book as an authenticated user
    # Create a dynamic user and get a valid access token.
    * def auth = call read('classpath:features/auth/helpers/auth.feature')

    # Pick an existing category for the new book.
    * def categoryResult = call read('classpath:features/categories/helpers/get-random-category.feature')
    * def categoryId = categoryResult.categoryId

    # Create the book, then verify it can be retrieved by id.
    * def createdBook = call read('classpath:features/books/helpers/create-book.feature') { token: '#(auth.token)', categoryId: '#(categoryId)' }
    * def bookId = createdBook.bookId

    * def foundBook = call read('classpath:features/books/helpers/get-book-by-id.feature') { bookId: '#(bookId)' }
    * match foundBook.getBookByIdResponse.response.id == bookId

    # Update only the price while keeping the original payload intact.
    * def bookPrice = generateBookPrice()
    * def updateFields = { price: '#(bookPrice)' }
    * def updatedBook = call read('classpath:features/books/helpers/update-book.feature') { token: '#(auth.token)', bookId: '#(bookId)', originalPayload: '#(createdBook.payload)', updateFields: '#(updateFields)' }
    * match updatedBook.updateBookResponse.response.price == bookPrice
