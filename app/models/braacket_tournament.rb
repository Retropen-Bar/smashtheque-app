# == Schema Information
#
# Table name: braacket_tournaments
#
#  id                     :bigint           not null, primary key
#  name                   :string
#  participants_count     :integer
#  slug                   :string           not null
#  start_at               :datetime
#  top1_participant_name  :string
#  top2_participant_name  :string
#  top3_participant_name  :string
#  top4_participant_name  :string
#  top5a_participant_name :string
#  top5b_participant_name :string
#  top7a_participant_name :string
#  top7b_participant_name :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_braacket_tournaments_on_slug  (slug) UNIQUE
#
class BraacketTournament < ApplicationRecord
  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include IsBracket

  # ---------------------------------------------------------------------------
  # CONSTANTS
  # ---------------------------------------------------------------------------

  PARTICIPANT_NAMES = TournamentEvent::TOP_RANKS.map do |rank|
    "top#{rank}_participant_name".to_sym
  end.freeze

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :slug, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.slug_from_url(input_url)
    url = input_url || ''
    return nil if url.starts_with?('http') && !url.starts_with?('https://braacket.com/tournament')

    url += '/' unless url.ends_with?('/')
    url.gsub(%r{https://braacket.com/tournament/}, '').gsub(%r{/.*}, '').presence
  end

  def braacket_url=(url)
    self.slug = self.class.slug_from_url(url)
  end

  def self.from_slug(slug)
    o = where(slug: slug).first_or_initialize
    o.fetch_braacket_data
    o
  end

  def self.from_url(url)
    slug = slug_from_url(url)
    slug && from_slug(slug)
  end

  def self.attributes_from_api_data(data)
    result = {
      slug: data[:slug],
      name: data[:name],
      start_at: data[:start_at] && DateTime.parse(data[:start_at]),
      participants_count: data[:participants_count]
    }
    data[:participants].each do |participant|
      placement = participant[:rank] || 0
      next unless placement.positive? && placement < 8

      idx =
        case placement
        when 5, 6
          result.key?(:top5a_participant_name) ? '5b' : '5a'
        when 7, 8
          result.key?(:top7a_participant_name) ? '7b' : '7a'
        else
          placement.to_s
        end
      result["top#{idx}_participant_name".to_sym] = [
        participant[:name]
      ].reject(&:blank?).first
    end
    result
  end

  def fetch_braacket_data
    api_data = BraacketClient.new.get_tournament(slug: slug)
    self.attributes = self.class.attributes_from_api_data(api_data) if api_data
  end

  def braacket_url
    slug && "https://braacket.com/tournament/#{slug}"
  end

  def self.participant_player(participant_name)
    return nil if participant_name.blank?

    player_ids = TournamentEvent::TOP_RANKS.map do |rank|
      joins(:tournament_event).where(
        "top#{rank}_participant_name" => participant_name
      ).pluck(
        "tournament_events.#{sanitize_sql("top#{rank}_player_id")}"
      )
    end.flatten.uniq.compact
    return Player.find(player_ids.first) if player_ids.count == 1

    nil
  end

  TournamentEvent::TOP_RANKS.each do |rank|
    define_method "top#{rank}_participant_player" do
      self.class.participant_player(send("top#{rank}_participant_name"))
    end
  end
end
