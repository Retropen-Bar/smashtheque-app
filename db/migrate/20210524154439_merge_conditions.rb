class MergeConditions < ActiveRecord::Migration[6.0]
  def change
    # Clean awards (they will be recomputed later)
    clean_awards

    # merge 1v1 and 2v2 reward conditions
    merge_reward_conditions

    # merge met conditions
    merge_met_conditions
  end

  private

  class DuoRewardDuoCondition < ApplicationRecord; end

  class RewardDuoCondition < ApplicationRecord; end

  class PlayerRewardCondition < ApplicationRecord; end

  def clean_awards
    change_table :players, bulk: true do |t|
      t.remove :best_player_reward_condition_id
      t.remove :best_reward_level1
      t.remove :best_reward_level2
    end
    drop_table :player_reward_conditions

    change_table :duos, bulk: true do |t|
      t.remove :best_duo_reward_duo_condition_id
      t.remove :best_reward_level1
      t.remove :best_reward_level2
    end
    drop_table :duo_reward_duo_conditions
  end

  def merge_reward_conditions
    add_column :reward_conditions, :is_duo, :boolean, null: false, default: false
    RewardDuoCondition.all.each do |rdc|
      RewardCondition.create!(
        rdc.attributes.symbolize_keys.slice(
          :reward_id, :size_min, :size_max, :rank, :points
        ).merge(
          is_duo: true
        )
      )
    end
    drop_table :reward_duo_conditions
  end

  def merge_met_conditions
    create_table :met_reward_conditions do |t|
      t.belongs_to :awarded, polymorphic: true, null: false
      t.belongs_to :reward_condition, null: false
      t.belongs_to :event, polymorphic: true, null: false
      t.timestamps
      t.index %i[awarded_type awarded_id reward_condition_id event_type event_id],
              name: :index_mrc_on_all,
              unique: true
    end
    add_foreign_key :met_reward_conditions, :reward_conditions
  end
end
