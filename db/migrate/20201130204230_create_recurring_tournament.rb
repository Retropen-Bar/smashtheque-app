class CreateRecurringTournament < ActiveRecord::Migration[6.0]
  def change
    create_table :recurring_tournaments do |t|
      t.string :name, null: false
      t.string :recurring_type, null: false
      t.integer :wday
      t.time :starts_at
      t.belongs_to :discord_guild
      t.boolean :is_online, null: false, default: false
      t.string :level
      t.integer :size
      t.text :registration
      t.timestamps
    end

    create_table :recurring_tournament_contacts do |t|
      t.belongs_to :recurring_tournament
      t.belongs_to :discord_user
      t.timestamps
    end

    add_index :recurring_tournament_contacts,
              [:recurring_tournament_id, :discord_user_id],
              name: 'index_rtc_on_both_ids',
              unique: true
  end
end
