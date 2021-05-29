class AllowOrphanTournamentEvents < ActiveRecord::Migration[6.0]
  def change
    change_column :tournament_events,
                  :recurring_tournament_id,
                  :integer,
                  null: true
    change_column :duo_tournament_events,
                  :recurring_tournament_id,
                  :integer,
                  null: true
  end
end
