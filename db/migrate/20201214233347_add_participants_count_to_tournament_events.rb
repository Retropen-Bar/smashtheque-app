class AddParticipantsCountToTournamentEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :tournament_events, :participants_count, :integer
  end
end
