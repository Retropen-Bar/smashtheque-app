class CreateRecurringTournamentPowerRankings < ActiveRecord::Migration[6.0]
  def change
    create_table :recurring_tournament_power_rankings do |t|
      t.belongs_to :recurring_tournament, null: false, foreign_key: true, index: { name: :index_rtpr_rt_id }
      t.string :name, null: false
      t.string :year
      t.string :url, null: false
      t.timestamps
    end
  end
end
