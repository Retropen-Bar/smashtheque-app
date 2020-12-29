class CreateSmashggEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :smashgg_events do |t|
      t.integer :smashgg_id, null: false
      t.string :slug, null: false

      # smash.gg data
      t.string :name
      t.datetime :start_at
      t.boolean :is_online
      t.integer :num_entrants
      t.integer :tournament_id
      t.string :tournament_slug
      t.string :tournament_name

      t.timestamps
    end
    add_index :smashgg_events, :smashgg_id, unique: true
    add_index :smashgg_events, :slug, unique: true

    add_reference :tournament_events, :smashgg_event
    add_foreign_key :tournament_events, :smashgg_events
  end
end
