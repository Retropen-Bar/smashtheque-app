class FixUserCountrycodes < ActiveRecord::Migration[6.0]
  def change
    User.where(main_countrycode: nil).update_all(main_countrycode: '')
    User.where(secondary_countrycode: nil).update_all(secondary_countrycode: '')
    change_column :users, :main_countrycode, :string, null: false, default: ''
    change_column :users, :secondary_countrycode, :string, null: false, default: ''
  end
end
