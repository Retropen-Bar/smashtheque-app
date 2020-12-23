# == Schema Information
#
# Table name: reward_conditions
#
#  id         :bigint           not null, primary key
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
#  index_reward_conditions_on_reward_id  (reward_id)
#
class RewardCondition < ApplicationRecord

  RANKS = [1, 2, 3, 4, 5, 7].freeze

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :reward

  has_many :player_reward_conditions, dependent: :destroy

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :size_min, presence: true
  validates :size_max, presence: true
  validates :rank,
            presence: true,
            inclusion: { in: RANKS }
  validates :points, presence: true

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :by_rank, -> v { where(rank: v) }

  def self.for_size(size)
    where("size_min <= ?", size).where("size_max >= ?", size)
  end

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
