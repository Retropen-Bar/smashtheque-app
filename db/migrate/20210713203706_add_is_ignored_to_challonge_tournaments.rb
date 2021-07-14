class AddIsIgnoredToChallongeTournaments < ActiveRecord::Migration[6.0]
  def change
    %i[braacket_tournaments challonge_tournaments].each do |t|
      add_column t, :is_ignored, :boolean, null: false, default: false
    end
  end
end
