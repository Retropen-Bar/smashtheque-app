# == Schema Information
#
# Table name: player_reward_conditions
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  player_id           :bigint           not null
#  reward_condition_id :bigint           not null
#  tournament_event_id :bigint           not null
#
# Indexes
#
#  index_player_reward_conditions_on_player_id            (player_id)
#  index_player_reward_conditions_on_reward_condition_id  (reward_condition_id)
#  index_player_reward_conditions_on_tournament_event_id  (tournament_event_id)
#  index_prc_on_all                                       (player_id,reward_condition_id,tournament_event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (player_id => players.id)
#  fk_rails_...  (reward_condition_id => reward_conditions.id)
#  fk_rails_...  (tournament_event_id => tournament_events.id)
#
class PlayerRewardCondition < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :player
  belongs_to :reward_condition
  belongs_to :tournament_event

  has_one :reward, through: :reward_condition

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  delegate :points,
           to: :reward_condition

  def self.points_total
    joins(:reward_condition).sum(:points)
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :by_player, -> v { where(player_id: v) }

end
