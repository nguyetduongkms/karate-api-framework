# ================================================================
# FEATURE: CATEGORIES API
# ================================================================
# Endpoint:
#   GET /api/categorys
#
# Purpose:
#   Verify that the API returns at least one valid category.
# ================================================================
Feature: Categories API
  Background:
    * url baseUrl

  @smoke @categories @happy-path
  Scenario: Get all categories
    Given path 'api', 'categorys'
    When method GET
    Then status 200
    And match response contains { message: 'Success', response: '#array' }
    And assert response.response.length > 0
    And match each response.response == { id: '#number', name: '#string' }

    * def categories = response.response