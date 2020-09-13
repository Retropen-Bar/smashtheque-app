# == Schema Information
#
# Table name: players_teams
#
#  id        :bigint           not null, primary key
#  position  :integer
#  player_id :bigint           not null
#  team_id   :bigint           not null
#
# Indexes
#
#  index_players_teams_on_player_id              (player_id)
#  index_players_teams_on_player_id_and_team_id  (player_id,team_id) UNIQUE
#  index_players_teams_on_team_id                (team_id)
#
class PlayersTeam < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :player
  belongs_to :team

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :team_id, uniqueness: { scope: :player_id }

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] || !player.is_legit? }
  def update_discord
    RetropenBotScheduler.rebuild_teams_lu
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.positioned
    order(:position)
  end

end
