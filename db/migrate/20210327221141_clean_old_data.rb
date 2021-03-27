class CleanOldData < ActiveRecord::Migration[6.0]
  def change
    drop_table :locations_players
    remove_column :players, :location_names
  end
end
