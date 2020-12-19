class CreatePlayerRewards < ActiveRecord::Migration[6.0]
  def change
    create_table :player_reward_conditions do |t|
      t.belongs_to :player, null: false
      t.foreign_key :players, column: :player_id
      t.belongs_to :reward_condition, null: false
      t.foreign_key :reward_conditions, column: :reward_condition_id
      t.belongs_to :tournament_event, null: false
      t.foreign_key :tournament_events, column: :tournament_event_id
      t.timestamps
    end

    add_index :player_reward_conditions,
              [
                :player_id,
                :reward_condition_id,
                :tournament_event_id
              ],
              name: :index_prc_on_all,
              unique: true
  end
end
