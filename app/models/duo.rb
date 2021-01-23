# == Schema Information
#
# Table name: duos
#
#  id                                  :bigint           not null, primary key
#  best_reward_level1                  :string
#  best_reward_level2                  :string
#  name                                :string           not null
#  points                              :integer          default(0), not null
#  rank                                :integer
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  best_duo_reward_duo_condition_id_id :bigint
#  player1_id                          :bigint           not null
#  player2_id                          :bigint           not null
#
# Indexes
#
#  index_duos_on_best_duo_reward_duo_condition_id_id  (best_duo_reward_duo_condition_id_id)
#  index_duos_on_name                                 (name)
#  index_duos_on_player1_id                           (player1_id)
#  index_duos_on_player2_id                           (player2_id)
#
# Foreign Keys
#
#  fk_rails_...  (best_duo_reward_duo_condition_id_id => duo_reward_duo_conditions.id)
#  fk_rails_...  (player1_id => players.id)
#  fk_rails_...  (player2_id => players.id)
#
class Duo < ApplicationRecord

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

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  pg_search_scope :by_keyword,
                  against: [:name],
                  associated_against: {
                    player1: :name,
                    player2: :name
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  def self.by_name_like(name)
    where('name ILIKE ?', name)
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
    super(options.merge(
      include: {
        player1: {
          only: %i(id name)
        },
        player2: {
          only: %i(id name)
        }
      }
    ))
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
      Reward.by_level(level1, level2).first
    end.sort_by(&:level2)
  end

  def update_points
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

  def update_cache!
    update_points
    update_best_reward
    save!
  end

  def self.update_ranks!
    subquery =
      Duo.with_points
         .select(:id, "ROW_NUMBER() OVER(ORDER BY points DESC) AS newrank")

    Duo.update_all("
      rank = pointed.newrank
      FROM (#{subquery.to_sql}) pointed
      WHERE duos.id = pointed.id
    ")
    Duo.where.not(id: Duo.with_points.select(:id)).update_all(rank: nil)
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
