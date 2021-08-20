# == Schema Information
#
# Table name: problems
#
#  id                      :bigint           not null, primary key
#  details                 :text             not null
#  nature                  :string           not null
#  occurred_at             :date             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  duo_id                  :bigint
#  player_id               :bigint
#  recurring_tournament_id :bigint
#  reporting_user_id       :bigint           not null
#
# Indexes
#
#  index_problems_on_duo_id                   (duo_id)
#  index_problems_on_nature                   (nature)
#  index_problems_on_occurred_at              (occurred_at)
#  index_problems_on_player_id                (player_id)
#  index_problems_on_recurring_tournament_id  (recurring_tournament_id)
#  index_problems_on_reporting_user_id        (reporting_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (duo_id => duos.id)
#  fk_rails_...  (player_id => players.id)
#  fk_rails_...  (recurring_tournament_id => recurring_tournaments.id)
#  fk_rails_...  (reporting_user_id => users.id)
#
class Problem < ApplicationRecord
  # ---------------------------------------------------------------------------
  # CONSTANTS
  # ---------------------------------------------------------------------------

  NATURE_GROUPS = {
    bad: %w[
      discriminating_players
      discriminating_admins
      harassing_players
      harassing_admins
      social_lynching_players
      social_lynching_admins
    ],
    other: %w[
      verbal_players
      verbal_admins
      toxic_ingame
      bashing_gameplay
      depressed_player
      forcing_clips
    ],
    fake: %w[
      banned_and_doubling
      doubling
      cheating
      usurping
    ],
    dq: %w[
      frequently
      bad_checking_frequently
      with_warning
      without_warning
      multiple_tournaments
      dq_other_tournament
    ],
    lag: %w[
      test
      toxic
      input
    ]
  }.freeze
  NATURES = NATURE_GROUPS.map do |key, values|
    values.map { |val| "#{key}__#{val}" }
  end.flatten.freeze

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :reporting_user, class_name: :User
  belongs_to :player, optional: true
  belongs_to :duo, optional: true
  belongs_to :recurring_tournament, optional: true

  has_one_attached :proof

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :player, presence: true, if: -> { duo.nil? }

  validates :nature, inclusion: { in: NATURES }

  validates :occurred_at, presence: true

  validates :details, presence: true

  validates :proof, size: { less_than: 50.megabytes }

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :by_players, -> { where.not(player_id: nil) }
  scope :by_duos, -> { where.not(duo_id: nil) }

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  delegate :name,
           to: :player,
           prefix: true,
           allow_nil: true

  delegate :name,
           to: :duo,
           prefix: true,
           allow_nil: true

  def concerned
    player || duo
  end
end
