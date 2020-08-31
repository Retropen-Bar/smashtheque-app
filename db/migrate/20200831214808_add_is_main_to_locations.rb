class AddIsMainToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :is_main, :boolean
  end
end
