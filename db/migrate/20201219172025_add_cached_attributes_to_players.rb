class AddCachedAttributesToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :points, :integer
    add_reference :players, :best_player_reward_condition
    add_foreign_key :players, :player_reward_conditions, column: :best_player_reward_condition_id
    add_column :players, :best_reward_level1, :string
    add_column :players, :best_reward_level2, :string
  end
end
