class CreateDuoTournamentEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :duo_tournament_events do |t|
      t.belongs_to :recurring_tournament, null: false, foreign_key: true, index: true
      t.string :name, null: false
      t.date :date, null: false
      t.integer :participants_count
      t.string :bracket_url
      t.belongs_to :bracket, polymorphic: true, index: true
      t.belongs_to :top1_duo, foreign_key: { to_table: :duos }, index: true
      t.belongs_to :top2_duo, foreign_key: { to_table: :duos }, index: true
      t.belongs_to :top3_duo, foreign_key: { to_table: :duos }, index: true
      t.belongs_to :top4_duo, foreign_key: { to_table: :duos }, index: true
      t.belongs_to :top5a_duo, foreign_key: { to_table: :duos }, index: true
      t.belongs_to :top5b_duo, foreign_key: { to_table: :duos }, index: true
      t.belongs_to :top7a_duo, foreign_key: { to_table: :duos }, index: true
      t.belongs_to :top7b_duo, foreign_key: { to_table: :duos }, index: true
      t.boolean :is_complete, default: false, null: false
      t.timestamps
    end
  end
end
