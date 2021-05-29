class AddOfflineAttributesToRecurringTournaments < ActiveRecord::Migration[6.0]
  def change
    change_table :recurring_tournaments, bulk: true do |t|
      t.string :address_name
      t.string :address
      t.float :latitude
      t.float :longitude
      t.string :twitter_username
      t.text :misc
    end
  end
end
