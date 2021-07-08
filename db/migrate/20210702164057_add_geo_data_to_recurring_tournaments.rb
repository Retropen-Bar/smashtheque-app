class AddGeoDataToRecurringTournaments < ActiveRecord::Migration[6.0]
  def change
    change_table :recurring_tournaments, bulk: true do |t|
      t.string :locality
      t.string :countrycode
    end
  end
end
