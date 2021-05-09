class CreateBraacketTournaments < ActiveRecord::Migration[6.0]
  def change
    create_table :braacket_tournaments do |t|
      t.string :slug, null: false
      t.string :name
      t.datetime :start_at
      t.integer :participants_count
      t.string :top1_participant_name
      t.string :top2_participant_name
      t.string :top3_participant_name
      t.string :top4_participant_name
      t.string :top5a_participant_name
      t.string :top5b_participant_name
      t.string :top7a_participant_name
      t.string :top7b_participant_name
      t.timestamps
      t.index :slug, unique: true
    end
  end
end
