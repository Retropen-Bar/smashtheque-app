class AddLocationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :main_address, :string
    add_column :users, :main_latitude, :float
    add_column :users, :main_longitude, :float
    add_column :users, :secondary_address, :string
    add_column :users, :secondary_latitude, :float
    add_column :users, :secondary_longitude, :float
  end
end
