class AddIsOnlineToTournamentEvents < ActiveRecord::Migration[6.0]
  def change
    %i[tournament_events duo_tournament_events].each do |table_name|
      change_table table_name, bulk: true do |t|
        t.boolean :is_online, default: false, null: false
      end
    end
  end
end
