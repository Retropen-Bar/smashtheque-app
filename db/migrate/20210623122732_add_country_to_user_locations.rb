class AddCountryToUserLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :main_countrycode, :string
    add_column :users, :secondary_countrycode, :string
  end
end
