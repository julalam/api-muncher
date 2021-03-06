require 'httparty'
require 'will_paginate/array'

class EdamamApiWrapper
  BASE_URL = "https://api.edamam.com/search?"
  SEARCH_URL = "q="
  SHOW_URL = "r=http://www.edamam.com/ontologies/edamam.owl%23recipe_"
  TOKEN_ID = ENV["APP_ID"]
  TOKEN_KEY = ENV["APP_KEY"]
  CRED_URL = "&app_id=#{TOKEN_ID}&app_key=#{TOKEN_KEY}"
  NUMBER_URL = "&from=0&to=900"

  class ApiError < StandardError; end

  def self.search_recipes(search, token_id=TOKEN_ID, token_key=TOKEN_KEY)
    url = BASE_URL + SEARCH_URL + "#{search}" + "&app_id=#{token_id}&app_key=#{token_key}" + NUMBER_URL
    response = HTTParty.get(url)

    check_status(response)

    recipes = []
    if response["hits"]
      response["hits"].each do |recipe_data|
        recipes << create_recipe(recipe_data["recipe"])
      end
    else
      return []
    end
    return recipes
  end

  def self.show_recipe(id)
    url = BASE_URL + SHOW_URL + "#{id}" + CRED_URL
    response = HTTParty.get(url)

    check_status(response)

    if response.present?
      recipe = create_recipe(response[0])
      return recipe
    end
  end

  private

  def self.check_status(response)
    unless response.code == 200
      raise ApiError.new("API call to Edamam failed: #{response["error"]}")
    end
  end

  def self.create_recipe(api_params)
    return Recipe.new(
      api_params["uri"],
      api_params["label"],
      api_params["source"],
      api_params["url"],
      api_params["image"],
      api_params["ingredientLines"],
      api_params["healthLabels"]
    )
  end
end
