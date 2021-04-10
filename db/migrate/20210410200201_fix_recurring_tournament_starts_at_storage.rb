class FixRecurringTournamentStartsAtStorage < ActiveRecord::Migration[6.0]
  def change
    add_column :recurring_tournaments, :starts_at_hour, :integer
    add_column :recurring_tournaments, :starts_at_min, :integer
    RecurringTournament.find_each do |recurring_tournament|
      date = recurring_tournament.starts_at.in_time_zone('Paris')
      recurring_tournament.starts_at_hour = date.hour
      recurring_tournament.starts_at_min = date.min
      recurring_tournament.save!
    end
    change_column :recurring_tournaments, :starts_at_hour, :integer, null: false
    change_column :recurring_tournaments, :starts_at_min, :integer, null: false
    remove_column :recurring_tournaments, :starts_at
  end
end
