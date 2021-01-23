class AddRewardsToDuos < ActiveRecord::Migration[6.0]
  def change
    add_column :duos, :points, :integer, default: 0, null: false
    add_belongs_to :duos,
                   :best_duo_reward_duo_condition_id,
                   foreign_key: { to_table: :duo_reward_duo_conditions },
                   index: true
    add_column :duos, :best_reward_level1, :string
    add_column :duos, :best_reward_level2, :string
    add_column :duos, :rank, :integer
  end
end
