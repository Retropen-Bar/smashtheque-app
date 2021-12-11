class AddClosestCommunityToRecurringTournaments < ActiveRecord::Migration[6.0]
  def change
    change_table :recurring_tournaments, bulk: true do |t|
      t.belongs_to :closest_community, foreign_key: { to_table: :communities }
    end
  end
end
