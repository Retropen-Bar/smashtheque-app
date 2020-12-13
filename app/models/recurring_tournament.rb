# == Schema Information
#
# Table name: recurring_tournaments
#
#  id               :bigint           not null, primary key
#  date_description :string
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
    bimonthly
    monthly
    irregular
    oneshot
  ].freeze

  SIZES = [
    8,
    16,
    32,
    64,
    128,
    1024
  ]

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
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    RetropenBotScheduler.rebuild_online_tournaments
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :online, -> { where(is_online: true) }
  scope :offline, -> { where(is_online: false) }

  scope :by_level_in, -> v { where(level: v) }

  scope :by_size_geq, -> v { where("size >= ?", v) }
  scope :by_size_leq, -> v { where("size <= ?", v) }

  scope :weekly, -> { where(recurring_type: :weekly) }
  scope :bimonthly, -> { where(recurring_type: :bimonthly) }
  scope :monthly, -> { where(recurring_type: :monthly) }
  scope :irregular, -> { where(recurring_type: :irregular) }
  scope :oneshot, -> { where(recurring_type: :oneshot) }

  scope :recurring, -> { where(recurring_type: %i(weekly bimonthly monthly)) }
  scope :on_wday, -> v { where(wday: v) }

  def is_recurring?
    %i(weekly bimonthly monthly).include?(recurring_type.to_sym)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  delegate :invitation_url,
           to: :discord_guild,
           prefix: true,
           allow_nil: true

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
