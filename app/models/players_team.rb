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
# Foreign Keys
#
#  fk_rails_...  (player_id => players.id)
#  fk_rails_...  (team_id => teams.id)
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

  after_commit :update_team_track_records
  def update_team_track_records
    UpdateTeamTrackRecordsJob.perform_later(team)
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.positioned
    order(:position)
  end
end
