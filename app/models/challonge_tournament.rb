# == Schema Information
#
# Table name: challonge_tournaments
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
#  challonge_id           :integer          not null
#
# Indexes
#
#  index_challonge_tournaments_on_challonge_id  (challonge_id) UNIQUE
#  index_challonge_tournaments_on_slug          (slug) UNIQUE
#
class ChallongeTournament < ApplicationRecord

  PARTICIPANT_NAMES = TournamentEvent::PLAYER_RANKS.map do |rank|
    "top#{rank}_participant_name".to_sym
  end.freeze

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_one :tournament_event, as: :bracket, dependent: :nullify
  has_one :duo_tournament_event, as: :bracket, dependent: :nullify

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :challonge_id, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.with_tournament_event
    where(id: (
      TournamentEvent.by_bracket_type(:ChallongeTournament).select(:bracket_id)
    ))
  end
  def self.without_tournament_event
    where.not(id: (
      TournamentEvent.by_bracket_type(:ChallongeTournament).select(:bracket_id)
    ))
  end

  def self.with_duo_tournament_event
    where(id: (
      DuoTournamentEvent.by_bracket_type(:ChallongeTournament).select(:bracket_id)
    ))
  end
  def self.without_duo_tournament_event
    where.not(id: (
      DuoTournamentEvent.by_bracket_type(:ChallongeTournament).select(:bracket_id)
    ))
  end

  def self.with_any_tournament_event
    with_tournament_event.or(with_duo_tournament_event)
  end
  def self.without_any_tournament_event
    without_tournament_event.without_duo_tournament_event
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.slug_from_url(url)
    url.gsub(/https:\/\/challonge.com\//, '').gsub(/(fr|en)\//, '')
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
      start_at: data['start_at'] && DateTime.parse(data['start_at']),
      participants_count: data['participants_count']
    }
    data['participants'].each do |_participant|
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
          result["top#{idx}_participant_name".to_sym] = participant['name']
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

  def challonge_url
    slug && "https://challonge.com/#{slug}"
  end

  def any_tournament_event
    tournament_event || duo_tournament_event
  end

  # ---------------------------------------------------------------------------
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i(name)

end
