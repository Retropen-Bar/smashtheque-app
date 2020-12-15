class AddIsArchivedToRecurringTournaments < ActiveRecord::Migration[6.0]
  def change
    add_column :recurring_tournaments, :is_archived, :boolean, null: false, default: false
  end
end
