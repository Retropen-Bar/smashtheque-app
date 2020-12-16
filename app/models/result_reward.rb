# == Schema Information
#
# Table name: result_rewards
#
#  id         :bigint           not null, primary key
#  level      :string           not null
#  points     :integer          not null
#  rank       :integer          not null
#  size_max   :integer          not null
#  size_min   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  reward_id  :bigint
#
# Indexes
#
#  index_result_rewards_on_reward_id  (reward_id)
#
class ResultReward < ApplicationRecord

  belongs_to :reward

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :size_min, presence: true
  validates :size_max, presence: true
  validates :level,
            presence: true,
            inclusion: { in: RecurringTournament::LEVELS }
  validates :rank,
            presence: true,
            inclusion: { in: [1, 2, 3, 4, 5, 7] }
  validates :points, presence: true

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
