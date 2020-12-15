class CreateTournamentEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :tournament_events do |t|
      t.belongs_to :recurring_tournament, foreign_key: { to_table: :recurring_tournaments }
      t.string :name, null: false
      t.date :date, null: false
      t.belongs_to :top1_player, foreign_key: { to_table: :players }
      t.belongs_to :top2_player, foreign_key: { to_table: :players }
      t.belongs_to :top3_player, foreign_key: { to_table: :players }
      t.belongs_to :top4_player, foreign_key: { to_table: :players }
      t.belongs_to :top5a_player, foreign_key: { to_table: :players }
      t.belongs_to :top5b_player, foreign_key: { to_table: :players }
      t.belongs_to :top7a_player, foreign_key: { to_table: :players }
      t.belongs_to :top7b_player, foreign_key: { to_table: :players }
      t.timestamps
    end
  end
end
