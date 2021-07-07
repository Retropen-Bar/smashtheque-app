class FixUserCountrycodes < ActiveRecord::Migration[6.0]
  def change
    User.where(main_countrycode: nil).update_all(main_countrycode: '')
    User.where(secondary_countrycode: nil).update_all(secondary_countrycode: '')
    change_column_null(:users, :main_countrycode, false)
    change_column_null(:users, :secondary_countrycode, false)
  end
end
