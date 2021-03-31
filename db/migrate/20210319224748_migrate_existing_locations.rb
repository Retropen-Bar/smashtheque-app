class MigrateExistingLocations < ActiveRecord::Migration[6.0]
  # old classes
  class Location < ApplicationRecord; end
  class LocationsPlayer < ApplicationRecord
    belongs_to :location
    belongs_to :player
  end

  def change
    # remove STI column because we don't care about it right now
    # and it prevents us from migrating data properly
    remove_column :locations, :type

    # make sure all locations are geocoded
    Location.where(latitude: nil).find_each do |location|
      result = Geocoder.search(
        location.name,
        result_type: 'locality'
      ).first
      if result.nil?
        result = Geocoder.search(
          location.name
        ).first
      end
      location.latitude = result.latitude
      location.longitude = result.longitude
      location.save!
    end

    previous_player_id = nil
    LocationsPlayer.order(:player_id, :position).each do |lp|
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
