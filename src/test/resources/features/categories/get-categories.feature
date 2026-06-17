# ================================================================
# FEATURE: GET CATEGORIES API
# ================================================================
# Endpoint : GET https://api.anhtester.com/api/categorys
# Author   : TrungNguyen
# Version  : 1.0.0

  Feature: Get All Categories
    Purpose: Ensure the Get All Categories API returns all and valid categories.
    Endpoint: GET /api/categories

  Background:
    * url baseUrl
    * configure headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }

  # ================================================================
  # SCENARIO 1: SUCCESSFULLY GET ALL CATEGORIES (HAPPY PATH)
  # ================================================================
    @smoke @categories @happy-path
    Scenario: Successfully get all categories
    Given path '/api/categorys'
    When method GET
    Then status 200
    And match response.message == 'Success'
    And match response.response == '#array'
    And assert response.response.length > 0
    And match each response.response ==
      """
      {
        id: '#number',
        name: '#string'
      }
      """
    And match each response.response[*].id == '#number'
    And match each response.response[*].name == '#string'

