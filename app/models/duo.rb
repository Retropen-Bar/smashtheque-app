# == Schema Information
#
# Table name: duos
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  player1_id :bigint           not null
#  player2_id :bigint           not null
#
# Indexes
#
#  index_duos_on_name        (name)
#  index_duos_on_player1_id  (player1_id)
#  index_duos_on_player2_id  (player2_id)
#
# Foreign Keys
#
#  fk_rails_...  (player1_id => players.id)
#  fk_rails_...  (player2_id => players.id)
#
class Duo < ApplicationRecord
  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include HasName
  def self.on_abc_name
    :name
  end

  include HasProblems
  include HasTrackRecords

  include PgSearch::Model

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :player1, class_name: :Player
  belongs_to :player2, class_name: :Player

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :name, presence: true
  validate :unique_players
  validate :unique_team

  def unique_players
    if !player1_id.nil? && player1_id == player2_id
      errors.add(
        :player2_id,
        Duo.human_attribute_name(:player1)
      )
    end
  end

  def unique_team
    existing_team = (
      Duo.where.not(id: id).by_players(player1_id, player2_id).first
    ) || (
      Duo.where.not(id: id).by_players(player2_id, player1_id).first
    )
    if existing_team
      errors.add(
        :player1_id,
        existing_team.name
      )
      errors.add(
        :player2_id,
        existing_team.name
      )
    end
  end

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  pg_search_scope :by_pg_search,
                  against: [:name],
                  associated_against: {
                    player1: :name,
                    player2: :name
                  },
                  using: {
                    tsearch: { prefix: true }
                  },
                  ignoring: :accents

  def self.by_name(name)
    where(name: name)
  end

  def self.by_name_like(name)
    where('unaccent(name) ILIKE unaccent(?)', name)
  end

  def self.by_name_contains_like(term)
    where("unaccent(name) ILIKE unaccent(?)", "%#{term}%")
  end

  def self.by_keyword(term)
    by_name_contains_like(term).or(
      where(id: by_pg_search(term).select(:id))
    )
  end

  def self.by_player1(player_id)
    where(player1_id: player_id)
  end

  def self.by_player2(player_id)
    where(player2_id: player_id)
  end

  def self.by_player(player_id)
    by_player1(player_id).or(by_player2(player_id))
  end

  def self.by_players(player1_id, player2_id)
    by_player1(player1_id).by_player2(player2_id)
  end

  def self.by_discord_id(discord_id)
    by_player(
      Player.by_discord_id(discord_id).select(:id)
    )
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  delegate :name,
           to: :player1,
           prefix: true,
           allow_nil: true

  delegate :name,
           to: :player2,
           prefix: true,
           allow_nil: true

  def as_json(options = {})
    super(options).merge(
      player1: player1.as_json,
      player2: player2.as_json
    )
  end

  def duo_tournament_events
    DuoTournamentEvent.with_duo(id)
  end

  def is_legit?
    player1.is_legit? && player2.is_legit?
  end

  # ---------------------------------------------------------------------------
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i[name]

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: proc { ENV['NO_PAPERTRAIL'] }
end
