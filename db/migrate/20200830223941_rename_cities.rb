class RenameCities < ActiveRecord::Migration[6.0]
  def change
    rename_table :cities, :locations
    rename_column :players, :city_id, :location_id
    add_column :locations, :type, :string
    change_column :locations, :type, :string, null: false
    add_index :locations, :type
  end
end
