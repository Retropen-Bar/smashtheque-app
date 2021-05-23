# == Schema Information
#
# Table name: reward_conditions
#
#  id         :bigint           not null, primary key
#  is_online  :boolean          default(FALSE), not null
#  points     :integer          not null
#  rank       :integer          not null
#  size_max   :integer          not null
#  size_min   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  reward_id  :integer          not null
#
# Indexes
#
#  index_reward_conditions_on_reward_id  (reward_id)
#
# Foreign Keys
#
#  fk_rails_...  (reward_id => rewards.id)
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

  scope :by_is_online, ->(v) { where(is_online: v) }
  scope :online, -> { where(is_online: true) }
  scope :offline, -> { where(is_online: false) }

  scope :by_rank, ->(v) { where(rank: v) }

  def self.for_size(size)
    where('size_min <= ?', size).where('size_max >= ?', size)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def online?
    is_online?
  end

  def offline?
    !online?
  end

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: proc { ENV['NO_PAPERTRAIL'] }
end
