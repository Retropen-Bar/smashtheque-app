# == Schema Information
#
# Table name: recurring_tournaments
#
#  id               :bigint           not null, primary key
#  is_online        :boolean          default(FALSE), not null
#  level            :string
#  name             :string           not null
#  recurring_type   :string           not null
#  registration     :text
#  size             :integer
#  starts_at        :time
#  wday             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  discord_guild_id :bigint
#
# Indexes
#
#  index_recurring_tournaments_on_discord_guild_id  (discord_guild_id)
#
class RecurringTournament < ApplicationRecord

  LEVELS = %w[
    l1_playground
    l2_anything
    l3_glory
    l4_experts
  ].freeze

  RECURRING_TYPES = %w[
    weekly
    monthly
  ].freeze

  SIZES = %w[
    8
    16
    32
    64
    128
  ].freeze

  belongs_to :discord_guild, optional: true

  has_many :recurring_tournament_contacts,
           inverse_of: :recurring_tournament,
           dependent: :destroy
  has_many :contacts,
           through: :recurring_tournament_contacts,
           source: :discord_user

  # ---------------------------------------------------------------------------
  # validations
  # ---------------------------------------------------------------------------

  validates :level, presence: true, inclusion: { in: LEVELS }
  validates :recurring_type, presence: true, inclusion: { in: RECURRING_TYPES }
  validates :wday, presence: true

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :online, -> { where(is_online: true) }
  scope :offline, -> { where(is_online: false) }

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
