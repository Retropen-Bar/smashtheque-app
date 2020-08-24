class AddCharacterNamesToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :character_names, :text, array: true, default: []
  end
end
