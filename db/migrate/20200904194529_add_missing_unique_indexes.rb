class AddMissingUniqueIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :characters_players, [:character_id, :player_id], unique: true
    add_index :locations_players, [:location_id, :player_id], unique: true
    add_index :players_teams, [:player_id, :team_id], unique: true
  end
end
