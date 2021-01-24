class AddOutOfRankingToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :tournament_events,
               :is_out_of_ranking,
               :boolean,
               default: false,
               null: false
    add_column :duo_tournament_events,
               :is_out_of_ranking,
               :boolean,
               default: false,
               null: false
  end
end
