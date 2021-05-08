class ChallongeClient
  API_BASE_URL = 'https://api.challonge.com/v1/'.freeze

  def initialize(api_key: nil)
    @api_key = api_key || ENV['CHALLONGE_API_KEY']
  end

  def get_tournament(slug:)
    # Débutdelasaison1 -> D%C3%A9butdelasaison1
    api_result = api_get(
      "tournaments/#{CGI.escape(slug)}",
      { include_participants: 1 }
    )&.fetch('tournament', nil)
    api_result || web_get(slug: slug)
  end

  private

  def api_get(path, params = {})
    params[:api_key] = @api_key
    url = URI("#{API_BASE_URL}#{path}.json")
    url.query = params.to_query
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    response = https.request(request)
    JSON.parse(response.read_body)
  end

  def web_get(slug:)
    url = "https://challonge.com/fr/#{slug}/standings"
    doc = Nokogiri::HTML(URI.parse(url).open.read, nil, 'UTF-8')

    data = parse_web_data(doc)
    data[:url] = slug
    data[:participants] = parse_web_standings(doc)

    data.deep_stringify_keys
  end

  def parse_web_data(doc)
    data_tag = doc.css('div#presence-mount')[0]
    {
      id: data_tag['data-tournament-id'],
      name: data_tag['data-tournament-name'],
      start_at: doc.css('div.tournament-banner div.start-time')[0].text,
      participants_count: doc.css(
        'div.tournament-banner ul.inline-meta-list li.item'
      )[0].css('div.text')[0].text.to_i
    }
  end

  def parse_web_standings(doc)
    previous_rank = 0
    doc.css('table.standings tbody tr').map do |tr|
      rank = tr.css('td.rank').text.to_i
      rank = previous_rank if rank.zero?
      previous_rank = rank
      display_name = tr.css('td.display_name span').text
      {
        participant: {
          final_rank: rank,
          display_name: display_name
        }
      }
    end
  end
end
