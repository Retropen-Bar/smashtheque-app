class RemoveOldPlayerAttributes < ActiveRecord::Migration[6.0]
  def change
    remove_column :players, :location_id
    remove_column :players, :team_id
  end
end
