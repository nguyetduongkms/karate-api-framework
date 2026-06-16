# ================================================================
# HELPER: GET FIRST CATEGORY API
# ================================================================
# Endpoint : GET /api/categorys
# Author   : TrungNguyen
# Version  : 1.0.0
#
# Purpose:
#   Get all categories and return the first valid category_id.
#
# Called by other features via:
#   * def categoryResult = call read('classpath:features/categories/helpers/get-first-category.feature')
#
# Returns:
#   categoryResult.category_id
#   categoryResult.getCategoriesResponse
#
# @ignore prevents this helper from running as a standalone test.
# ================================================================

@ignore
Feature: Get First Category Helper

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  Scenario: Get first valid category
    Given path '/api/categorys'
    When method GET
    Then status 200

  # Validate top-level response
    And match response.message == 'Success'
    And match response.response == '#array'
    And assert response.response.length > 0

  # Validate every category object has expected schema
    And match each response.response ==
  """
  {
    id: '#number',
    name: '#string'
  }
  """

  # Get first category from response array
    * def category = response.response[0]

  # Validate selected category
    * match category.id == '#number'
    * match category.name == '#string'
    * assert category.name.length > 0

  # Expose clean values to caller
    * def category_id = category.id
    * def getCategoriesResponse = response