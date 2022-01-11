class BraacketClient
  def get_tournament(slug:)
    web_get(slug: slug)
  end

  private

  def web_get(slug:)
    data = parse_web_data(slug: slug)
    data[:participants] = parse_csv_ranking(slug: slug)
    data
  end

  def parse_web_data(slug:)
    url = "https://braacket.com/tournament/#{slug.strip}"
    doc = Nokogiri::HTML(URI.parse(url).open.read, nil, 'UTF-8')

    participants_count_tag = doc.css('div#content_header i.fa-users').first&.parent&.next_element

    {
      slug: slug,
      name: doc.css('title').first.text.gsub(%r{\s*/\sDashboard}, ''),
      start_at: doc.css('div#content_header i.fa-calendar').first&.parent&.next_element&.text,
      participants_count: participants_count_tag&.text&.gsub(%r{\s*}, '')&.gsub(%r{/.*}, '')&.to_i
    }
  end

  def parse_csv_ranking(slug:)
    url = "https://braacket.com/tournament/#{slug.strip}/ranking?rows=20&cols=&page=1&page_cols=1&game_character=&country=&search=&export=csv"

    CSV.parse(URI.parse(url).open.read, headers: true).map do |row|
      {
        rank: row['Rank'].to_i,
        name: row['Player']
      }
    end
  end
end
