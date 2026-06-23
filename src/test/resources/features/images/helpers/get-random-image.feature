# ================================================================
# HELPER: GET RANDOM IMAGES
# ================================================================
# Endpoint:
#   GET /api/images
#
# Purpose:
#   Read images and expose random valid image id.
#
# Returns:
#   imageId
# ================================================================
@ignore
Feature: Get a random available image
  Background:
    * url baseUrl

  Scenario: Get a random available image
    Given path 'api', 'images'
    When method GET
    Then status 200
    And match response contains { message: 'Success', response: '#array' }
    And assert response.response.length > 0
    And match each response.response == { id: '#number? _ > 0', path: '#regex public/images/[A-Za-z0-9]+\\.(jpg|jpeg|png|gif|webp)' }

    * def randomIndex = Math.floor(Math.random() * response.response.length)
    * def image = response.response[randomIndex]

    * def imageId = image.id