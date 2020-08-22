class Team < ApplicationRecord

  has_many :players, dependent: :nullify

  validates :short_name, presence: true
  validates :name, presence: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    # on create: previous_changes = {"id"=>[nil, <id>], "name"=>[nil, <name>], ...}
    # on update: previous_changes = {"name"=>["old_name", "new_name"], ...}
    # on delete: destroyed? = true and old attributes are available

    # in any case, both the teams list and the teams lineups must be updated
    RetropenBot.default.rebuild_teams
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.on_abc(letter)
    where("unaccent(name) ILIKE '#{letter}%'")
  end

  # ---------------------------------------------------------------------------
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i(name)

end
