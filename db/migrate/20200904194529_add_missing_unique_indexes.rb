class AddMissingUniqueIndexes < ActiveRecord::Migration[6.0]
  def change
    CharactersPlayer.where(character_id: nil).delete_all
    change_column :characters_players, :character_id, :bigint, null: false
    CharactersPlayer.where(player_id: nil).delete_all
    change_column :characters_players, :player_id, :bigint, null: false
    add_index :characters_players, [:character_id, :player_id], unique: true

    change_column :locations_players, :location_id, :bigint, null: false
    change_column :locations_players, :player_id, :bigint, null: false
    add_index :locations_players, [:location_id, :player_id], unique: true

    PlayersTeam.where(player_id: nil).delete_all
    change_column :players_teams, :player_id, :bigint, null: false
    PlayersTeam.where(team_id: nil).delete_all
    change_column :players_teams, :team_id, :bigint, null: false
    add_index :players_teams, [:player_id, :team_id], unique: true
  end
end
