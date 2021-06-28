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
  end
end
