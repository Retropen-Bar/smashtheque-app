class AddBracketUrlToTournamentEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :tournament_events, :bracket_url, :string
  end
end
