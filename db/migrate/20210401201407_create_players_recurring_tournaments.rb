class CreatePlayersRecurringTournaments < ActiveRecord::Migration[6.0]
  def change
    create_table :players_recurring_tournaments do |t|
      t.belongs_to :player
      t.belongs_to :recurring_tournament

      t.boolean :has_good_network, default: false, null: false
      t.belongs_to :certifier_user

      t.timestamps
      t.index [:player_id, :recurring_tournament_id],
              unique: true,
              name: :index_prt_on_both_ids
    end
    add_foreign_key :players_recurring_tournaments, :players
    add_foreign_key :players_recurring_tournaments, :recurring_tournaments
    add_foreign_key :players_recurring_tournaments,
                    :users,
                    column: :certifier_user_id
  end
end
