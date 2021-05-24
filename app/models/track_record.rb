# == Schema Information
#
# Table name: track_records
#
#  id                           :bigint           not null, primary key
#  best_reward_level1           :string
#  best_reward_level2           :string
#  is_online                    :boolean          default(FALSE), not null
#  points                       :integer          not null
#  rank                         :integer          not null
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
  TRACKED_TYPES = %w[Duo Player].freeze

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :tracked, polymorphic: true

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :tracked_type,
            inclusion: {
              in: TRACKED_TYPES
            }

  validates :year,
            inclusion: {
              in: points_years,
              allow_nil: true
            }

  validates :points,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0
            }

  validates :rank,
            presence: true,
            numericality: {
              greater_than: 0
            }

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.points_years
    (POINTS_FIRST_YEAR..Time.now.utc.year).to_a
  end
end
