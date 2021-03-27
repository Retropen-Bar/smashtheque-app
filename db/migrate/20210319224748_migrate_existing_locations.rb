class MigrateExistingLocations < ActiveRecord::Migration[6.0]
  class LocationsPlayer < ApplicationRecord
    belongs_to :location
    belongs_to :player
  end

  def change
    previous_player_id = nil
    LocationsPlayer.order(:player_id, :position).find_each do |lp|
      location = lp.location
      raise "Location ##{location.id}: #{location.name} not geocoded" if location.latitude.nil?
      player = lp.player
      user = player.return_or_create_user!

      if previous_player_id == player.id
        user.secondary_address = location.name
        user.secondary_latitude = location.latitude
        user.secondary_longitude = location.longitude
      else
        user.main_address = location.name
        user.main_latitude = location.latitude
        user.main_longitude = location.longitude
      end
      user.save!

      previous_player_id = player.id
    end
  end
end
