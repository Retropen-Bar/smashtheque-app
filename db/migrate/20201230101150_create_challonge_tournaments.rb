class CreateChallongeTournaments < ActiveRecord::Migration[6.0]
  def change
    create_table :challonge_tournaments do |t|
      t.integer :challonge_id, null: false
      t.string :slug, null: false

      # Challonge data
      t.string :name
      t.datetime :start_at
      t.integer :participants_count

      # Results
      t.string :top1_participant_name
      t.string :top2_participant_name
      t.string :top3_participant_name
      t.string :top4_participant_name
      t.string :top5a_participant_name
      t.string :top5b_participant_name
      t.string :top7a_participant_name
      t.string :top7b_participant_name

      t.timestamps
    end
    add_index :challonge_tournaments, :challonge_id, unique: true
    add_index :challonge_tournaments, :slug, unique: true

    add_reference :tournament_events, :challonge_tournament
    add_foreign_key :tournament_events, :challonge_tournaments
  end
end
