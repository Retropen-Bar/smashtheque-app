class AddPositionToCharactersPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :characters_players, :position, :integer
  end
end
