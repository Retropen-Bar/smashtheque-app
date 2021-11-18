# == Schema Information
#
# Table name: met_reward_conditions
#
#  id                  :bigint           not null, primary key
#  awarded_type        :string           not null
#  event_type          :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  awarded_id          :bigint           not null
#  event_id            :bigint           not null
#  reward_condition_id :bigint           not null
#
# Indexes
#
#  index_met_reward_conditions_on_awarded_type_and_awarded_id  (awarded_type,awarded_id)
#  index_met_reward_conditions_on_event_type_and_event_id      (event_type,event_id)
#  index_met_reward_conditions_on_reward_condition_id          (reward_condition_id)
#  index_mrc_on_all                                            (awarded_type,awarded_id,reward_condition_id,event_type,event_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (reward_condition_id => reward_conditions.id)
#
class MetRewardCondition < ApplicationRecord
  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :awarded, polymorphic: true
  belongs_to :reward_condition
  belongs_to :event, polymorphic: true

  has_one :reward, through: :reward_condition

  has_many :bested_track_records,
           class_name: :TrackRecord,
           foreign_key: :best_met_reward_condition_id,
           dependent: :nullify

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_awarded_track_records
  def update_awarded_track_records
    awarded.update_track_records! unless awarded.destroyed?
    TrackRecord.update_all_ranks!(awarded.class)
    return unless awarded.is_a?(Player)

    awarded.teams.each(&:update_track_records!)
    TrackRecord.update_all_ranks!(Team)
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :by_awarded, ->(v) { where(awarded: v) }

  def self.on_year(year)
    where(
      event_type: :TournamentEvent,
      event_id: TournamentEvent.on_year(year).select(:id)
    ).or(
      where(
        event_type: :DuoTournamentEvent,
        event_id: DuoTournamentEvent.on_year(year).select(:id)
      )
    )
  end

  def self.by_is_online(val)
    where(reward_condition_id: RewardCondition.by_is_online(val).select(:id))
  end

  scope :online, -> { by_is_online(true) }
  scope :offline, -> { by_is_online(false) }

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  delegate :points,
           to: :reward_condition

  def self.points_total
    joins(:reward_condition).sum(:points)
  end
end
