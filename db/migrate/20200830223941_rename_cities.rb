class RenameCities < ActiveRecord::Migration[6.0]
  def change
    rename_table :cities, :locations
    rename_column :players, :city_id, :location_id
    add_column :locations, :type, :string
    Location.update_all(type: 'Locations::City')
    change_column :locations, :type, :string, null: false
    add_index :locations, :type
    PaperTrail::Version.where(item_type: 'City').update_all(item_type: 'Location')
  end
end
