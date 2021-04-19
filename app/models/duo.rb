# == Schema Information
#
# Table name: duos
#
#  id                               :bigint           not null, primary key
#  best_reward_level1               :string
#  best_reward_level2               :string
#  name                             :string           not null
#  points                           :integer          default(0), not null
#  points_in_2019                   :integer          default(0), not null
#  points_in_2020                   :integer          default(0), not null
#  points_in_2021                   :integer          default(0), not null
#  rank                             :integer
#  rank_in_2019                     :integer
#  rank_in_2020                     :integer
#  rank_in_2021                     :integer
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  best_duo_reward_duo_condition_id :bigint
#  player1_id                       :bigint           not null
#  player2_id                       :bigint           not null
#
# Indexes
#
#  index_duos_on_best_duo_reward_duo_condition_id  (best_duo_reward_duo_condition_id)
#  index_duos_on_name                              (name)
#  index_duos_on_player1_id                        (player1_id)
#  index_duos_on_player2_id                        (player2_id)
#
# Foreign Keys
#
#  fk_rails_...  (best_duo_reward_duo_condition_id => duo_reward_duo_conditions.id)
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

  include HasPoints

  include PgSearch::Model

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :player1, class_name: :Player
  belongs_to :player2, class_name: :Player

  # cache
  belongs_to :best_duo_reward_duo_condition,
             class_name: :DuoRewardDuoCondition,
             optional: true

  has_one :best_reward,
          through: :best_duo_reward_duo_condition,
          source: :reward

  has_many :duo_reward_duo_conditions, dependent: :destroy
  has_many :reward_duo_conditions, through: :duo_reward_duo_conditions
  has_many :rewards, through: :duo_reward_duo_conditions

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

  # returns a hash { reward_id => count }
  def rewards_counts
    rewards.ordered_by_level.group(:id).count
  end

  def unique_rewards
    Reward.where(id: rewards.select(:id))
  end

  def best_rewards
    Hash[
      rewards.order(:level1).group(:level1).pluck(:level1, "MAX(level2)")
    ].map do |level1, level2|
      Reward.online_2v2.by_level(level1, level2).first
    end.sort_by(&:level2)
  end

  def update_points
    Player::POINTS_YEARS.each do |year|
      self.attributes = {
        "points_in_#{year}" => (
          duo_reward_duo_conditions.on_year(year).points_total
        )
      }
    end
    self.points = duo_reward_duo_conditions.points_total
  end

  def update_best_reward
    duo_reward_duo_condition =
      duo_reward_duo_conditions.joins(:reward)
                              .order(:level1, :level2, :points)
                              .last
    self.best_duo_reward_duo_condition = duo_reward_duo_condition
    self.best_reward_level1 = duo_reward_duo_condition&.reward&.level1
    self.best_reward_level2 = duo_reward_duo_condition&.reward&.level2
  end

  # ---------------------------------------------------------------------------
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i(name)

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
