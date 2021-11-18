# == Schema Information
#
# Table name: track_records
#
#  id                           :bigint           not null, primary key
#  best_reward_level1           :string
#  best_reward_level2           :string
#  is_online                    :boolean          default(FALSE), not null
#  points                       :integer          not null
#  rank                         :integer
#  tracked_type                 :string           not null
#  year                         :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  best_met_reward_condition_id :integer
#  tracked_id                   :bigint           not null
#
# Indexes
#
#  index_track_records_on_all                          (tracked_type,tracked_id,year,is_online) UNIQUE
#  index_track_records_on_tracked_type_and_tracked_id  (tracked_type,tracked_id)
#
# Foreign Keys
#
#  fk_rails_...  (best_met_reward_condition_id => met_reward_conditions.id)
#
class TrackRecord < ApplicationRecord
  # ---------------------------------------------------------------------------
  # CONSTANTS
  # ---------------------------------------------------------------------------

  POINTS_FIRST_YEAR = 2019
  TRACKED_TYPES = %w[Duo Player Team].freeze

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :tracked, polymorphic: true
  belongs_to :best_met_reward_condition, class_name: :MetRewardCondition

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :tracked_type,
            inclusion: {
              in: TRACKED_TYPES
            }

  validates :year,
            inclusion: {
              in: proc { points_years },
              allow_nil: true
            }

  validates :points,
            presence: true,
            numericality: {
              greater_than: 0
            }

  validates :rank,
            numericality: {
              greater_than: 0,
              allow_nil: true
            }

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :by_tracked_type, ->(v) { where(tracked_type: v.to_s.classify) }

  scope :all_time, -> { where(year: nil) }
  scope :on_year, ->(v) { where(year: v) }

  scope :by_is_online, ->(v) { where(is_online: v) }
  scope :online, -> { by_is_online(true) }
  scope :offline, -> { by_is_online(false) }

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def online?
    is_online?
  end

  def offline?
    !online?
  end

  def self.points_years
    (POINTS_FIRST_YEAR..Time.now.utc.year).to_a
  end

  def update_best_rewards
    met_reward_conditions = tracked.met_reward_conditions.by_is_online(online?)
    met_reward_conditions = met_reward_conditions.on_year(year) if year
    met_reward_condition =
      met_reward_conditions.joins(:reward).order(:level1, :level2, :points).last
    self.best_met_reward_condition = met_reward_condition
    self.best_reward_level1 = met_reward_condition&.reward&.level1
    self.best_reward_level2 = met_reward_condition&.reward&.level2
  end

  def self.update_ranks!(tracked_type:, is_online:, year:)
    subquery =
      by_tracked_type(tracked_type).by_is_online(is_online).on_year(year).select(
        :id,
        'ROW_NUMBER() OVER(ORDER BY points DESC) AS newrank'
      )

    update_all("
      rank = ranked.newrank
      FROM (#{subquery.to_sql}) ranked
      WHERE #{table_name}.id = ranked.id
    ")
  end

  def self.update_all_ranks!(tracked_types = TRACKED_TYPES)
    [tracked_types].flatten.each do |tracked_type|
      [false, true].each do |is_online|
        ([nil] + points_years).each do |year|
          update_ranks!(tracked_type: tracked_type, is_online: is_online, year: year)
        end
      end
    end
  end
end
