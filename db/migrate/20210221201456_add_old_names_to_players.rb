class AddOldNamesToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :old_names, :string, array: true, default: []
  end
end
