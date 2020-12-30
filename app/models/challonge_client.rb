class ChallongeClient

  API_BASE_URL = 'https://api.challonge.com/v1/'.freeze

  def initialize(apiKey: nil)
    @apiKey = apiKey || ENV['CHALLONGE_API_KEY']
  end

  def get_tournament(slug:)
    api_get("tournaments/#{slug}", {include_participants: 1})&.fetch('tournament', nil)
  end

  private

  def api_get(path, params = {})
    params[:api_key] = @apiKey
    puts "=== CHALLONGE API REQUEST ==="
    url = URI("#{API_BASE_URL}#{path}.json")
    url.query = params.to_query
    puts "GET #{url}"

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)

    response = https.request(request)

    JSON.parse(response.read_body)
  end

end
