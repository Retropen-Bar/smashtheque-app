# == Schema Information
#
# Table name: rewards
#
#  id         :bigint           not null, primary key
#  emoji      :string           not null
#  level1     :integer          not null
#  level2     :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_rewards_on_level1_and_level2  (level1,level2) UNIQUE
#
class Reward < ApplicationRecord

  has_many :reward_conditions, dependent: :destroy

  has_many :player_reward_conditions, through: :reward_conditions
  has_many :players, through: :player_reward_conditions

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :name, presence: true, uniqueness: true
  validates :level1,
            presence: true,
            numericality: {
              greater_than: 0
            }
  validates :level2,
            presence: true,
            numericality: {
              greater_than: 0
            },
            uniqueness: {
              scope: :level1
            }

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :by_level1, -> v { where(level1: v) }
  scope :by_level2, -> v { where(level2: v) }
  scope :by_level, -> (a, b) { where(level1: a, level2: b) }

  def self.ordered_by_level(asc = true)
    if asc
      order(:level1, :level2)
    else
      order(level1: :desc, level2: :desc)
    end
  end

  def self.grouped_by_level2
    ordered_by_level.group_by(&:level2).to_a
  end

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
