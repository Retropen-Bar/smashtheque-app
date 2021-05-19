class AddLocalityFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :main_locality
      t.string :secondary_locality
    end
    User.update_all(
      'main_locality = main_address, secondary_locality = secondary_address'
    )
  end
end
