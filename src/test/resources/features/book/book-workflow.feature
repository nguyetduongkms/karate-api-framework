# ================================================================
# FEATURE: BOOK WORKFLOW API
# ================================================================
# Endpoint chain:
#   POST /api/register
#   POST /api/login
#   GET  /api/categorys
#   POST /api/book
#   GET /api/book/{id}
#   PUT /api/book/{id}
#
# Author  : TrungNguyen
# Version : 1.0.0
#
# Purpose:
#   Verify that a user can register, login, get a valid category,
#   create a new book, get it by id, and update its price successfully.
# ================================================================

Feature: Book Workflow

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

# ================================================================
# SCENARIO 1: SUCCESSFUL BOOK WORKFLOW
# ================================================================

  @smoke @books @happy-path
  Scenario: Successful book workflow after register, login, get category, create book, get book by id and update its price

  # ------------------------------------------------------------
  # STEP 1: Create a new user
  # ------------------------------------------------------------
    * def user = call read('classpath:features/auth/helpers/create-user.feature')
    * match user.userId == '#notnull'

  # ------------------------------------------------------------
  # STEP 2: Login with the created user
  # ------------------------------------------------------------
    * def loginResult = call read('classpath:features/auth/helpers/login-user.feature') { username: '#(user.username)', password: '#(user.password)' }

    * def token = loginResult.token
    * match loginResult.token == '#string'
    * match loginResult.token != ''

  # ------------------------------------------------------------
  # STEP 3: Get a valid category ID
  # ------------------------------------------------------------
    * def categoryResult = call read('classpath:features/category/helpers/get-first-category.feature')

  # Validate category data
    * def categoryId = categoryResult.categoryId
    * match categoryResult.categoryId == '#number'

  # ------------------------------------------------------------
  # STEP 4: Create a new book
  # ------------------------------------------------------------
    * def createdBook = call read('classpath:features/book/helpers/create-book.feature') { token: '#(token)', categoryId: '#(categoryId)' }
    * def bookId = createdBook.bookId

  #-------------------------------------------------------------
  # STEP 5: Get book by id
  # ------------------------------------------------------------
    * def getBookById = call read('classpath:features/book/helpers/get-book-by-id.feature') {bookId: '#(bookId)'}
    * match getBookById.getBookByIdResponse.response.id == bookId

  # ------------------------------------------------------------
  # STEP 6: Update book price by id
  # ------------------------------------------------------------
    * def bookPrice = generateBookPrice()
    * def updateFields = { price: '#(bookPrice)' }
    * def updatedBook = call read('classpath:features/book/helpers/update-book.feature') { token: '#(token)', bookId: '#(bookId)', originalPayload: '#(createdBook.payload)', updateFields: '#(updateFields)' }
    * match updatedBook.updateBookResponse.response.price == bookPrice

