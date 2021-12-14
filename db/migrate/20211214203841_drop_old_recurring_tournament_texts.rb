class DropOldRecurringTournamentTexts < ActiveRecord::Migration[6.0]
  def change
    remove_column :recurring_tournaments, :misc, :text
    remove_column :recurring_tournaments, :registration, :text
  end
end
