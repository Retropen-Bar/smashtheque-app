class CleanLocations < ActiveRecord::Migration[6.0]
  # old classes
  class Location < ApplicationRecord; end

  def change
    drop_table :locations_players
    remove_column :players, :location_names
    remove_column :locations, :is_main
    remove_column :locations, :icon
    add_column :locations, :address, :string
    Location.update_all("address = name")
    change_column :locations, :address, :string, null: false
    Location.where(latitude: nil).delete_all
    change_column :locations, :latitude, :float, null: false
    change_column :locations, :longitude, :float, null: false
    change_column :locations, :name, :string, null: false
  end
end
