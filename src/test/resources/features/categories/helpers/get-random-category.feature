# ================================================================
# HELPER: GET RANDOM CATEGORY
# ================================================================
# Endpoint:
#   GET /api/categorys
#
# Purpose:
#   Read categories and expose random valid category id.
#
# Returns:
#   categoryId
# ================================================================
@ignore
Feature: Get a random available category
  Background:
    * url baseUrl

  Scenario: Get random available category
    Given path 'api', 'categorys'
    When method get
    Then status 200
    And match response contains { message: 'Success', response: '#array' }
    And assert response.response.length > 0
    And match each response.response == { id: '#number', name: '#string' }

    * def randomIndex = Math.floor(Math.random() * response.response.length)
    * def category = response.response[randomIndex]

    * def categoryId = category.id