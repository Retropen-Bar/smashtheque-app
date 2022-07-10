# == Schema Information
#
# Table name: challonge_tournaments
#
#  id                     :bigint           not null, primary key
#  is_ignored             :boolean          default(FALSE), not null
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
#  challonge_id           :integer          not null
#
# Indexes
#
#  index_challonge_tournaments_on_challonge_id  (challonge_id) UNIQUE
#  index_challonge_tournaments_on_slug          (slug) UNIQUE
#
class ChallongeTournament < ApplicationRecord
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
  ICON_URL = 'https://assets.challonge.com/assets/challonge_fireball_orange-a973ff3b12c34c780fc21313ec71aada3b9b779cbd3a62769e9199ce08395692.svg'.freeze

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :challonge_id, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.slug_from_url(input_url)
    url = input_url || ''
    return nil if url.starts_with?('http') && !url.starts_with?('https://challonge.com')

    url += '/' unless url.ends_with?('/')
    url.gsub(%r{https://challonge.com/}, '').gsub(%r{(fr|en)/}, '').gsub(%r{/.*}, '').presence
  end

  def challonge_url=(url)
    self.slug = self.class.slug_from_url(url)
  end

  def self.from_slug(slug)
    o = where(slug: slug).first_or_initialize
    o.fetch_challonge_data
    o
  end

  def self.from_url(url)
    if slug = slug_from_url(url)
      from_slug(slug)
    else
      nil
    end
  end

  def self.attributes_from_api_data(data)
    result = {
      challonge_id: data['id'],
      slug: data['url'],

      name: data['name'],
      participants_count: data['participants_count']
    }
    result[:start_at] = DateTime.parse(data['start_at']) if data['start_at']
    (data['participants'] || []).each do |_participant|
      if participant = _participant['participant']
        placement = participant['final_rank']
        if (placement || 0) > 0 && placement < 8
          idx = case placement
          when 5, 6
            result.has_key?(:top5a_participant_name) ? '5b' : '5a'
          when 7, 8
            result.has_key?(:top7a_participant_name) ? '7b' : '7a'
          else
            placement.to_s
          end
          result["top#{idx}_participant_name".to_sym] = [
            participant['display_name'],
            participant['name'],
            participant['username'],
            participant['challonge_username']
          ].reject(&:blank?).first
        end
      end
    end
    result
  end

  def fetch_challonge_data
    if api_data = ChallongeClient.new.get_tournament(slug: slug)
      self.attributes = self.class.attributes_from_api_data(api_data)
    end
  end

  alias_method :fetch_provider_data, :fetch_challonge_data

  def challonge_url
    slug && "https://challonge.com/#{slug}"
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

  # ---------------------------------------------------------------------------
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i[name]
end
