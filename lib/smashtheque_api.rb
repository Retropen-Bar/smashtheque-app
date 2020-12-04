require "uri"
require "net/http"

class SmashthequeApi

  BASE_URL = 'https://www.smashtheque.fr/api/v1'.freeze
  AUTH_TOKEN = ENV['SMASHTHEQUE_API_TOKEN'].freeze

  def self.characters
    api_get 'characters'
  end

  def self.api_get(path)
    url = URI("#{BASE_URL}/#{path}")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer #{AUTH_TOKEN}"

    response = https.request(request)
    JSON.parse response.read_body
  end

end
