# == Schema Information
#
# Table name: duo_reward_duo_conditions
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  duo_id                  :bigint           not null
#  duo_tournament_event_id :bigint           not null
#  reward_duo_condition_id :bigint           not null
#
# Indexes
#
#  index_drdc_on_all                                           (duo_id,reward_duo_condition_id,duo_tournament_event_id) UNIQUE
#  index_duo_reward_duo_conditions_on_duo_id                   (duo_id)
#  index_duo_reward_duo_conditions_on_duo_tournament_event_id  (duo_tournament_event_id)
#  index_duo_reward_duo_conditions_on_reward_duo_condition_id  (reward_duo_condition_id)
#
# Foreign Keys
#
#  fk_rails_...  (duo_id => duos.id)
#  fk_rails_...  (duo_tournament_event_id => duo_tournament_events.id)
#  fk_rails_...  (reward_duo_condition_id => reward_duo_conditions.id)
#
class DuoRewardDuoCondition < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :duo
  belongs_to :reward_duo_condition
  belongs_to :duo_tournament_event

  has_one :reward, through: :reward_duo_condition

  has_one :bested_duo,
           class_name: :Duo,
           foreign_key: :best_duo_reward_duo_condition_id,
           dependent: :nullify

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_duo_cache
  def update_duo_cache
    duo.update_cache! unless duo.destroyed?
    Duo.update_ranks!
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  delegate :points,
           to: :reward_duo_condition

  def self.points_total
    joins(:reward_duo_condition).sum(:points)
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :by_duo, -> v { where(duo_id: v) }

end
