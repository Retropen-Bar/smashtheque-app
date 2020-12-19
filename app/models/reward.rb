# == Schema Information
#
# Table name: rewards
#
#  id         :bigint           not null, primary key
#  image      :text             not null
#  name       :string           not null
#  style      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Reward < ApplicationRecord

  has_many :reward_conditions, dependent: :destroy

  has_many :player_reward_conditions, through: :reward_conditions

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :name, presence: true, uniqueness: true
  validates :image, presence: true

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
