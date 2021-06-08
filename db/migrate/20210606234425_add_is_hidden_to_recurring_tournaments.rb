class AddIsHiddenToRecurringTournaments < ActiveRecord::Migration[6.0]
  def change
    add_column :recurring_tournaments, :is_hidden, :boolean, null: false, default: false
  end
end
