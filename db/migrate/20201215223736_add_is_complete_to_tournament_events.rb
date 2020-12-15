class AddIsCompleteToTournamentEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :tournament_events, :is_complete, :boolean, null: false, default: false
  end
end
