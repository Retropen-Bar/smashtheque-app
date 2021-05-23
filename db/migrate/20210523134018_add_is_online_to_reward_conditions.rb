class AddIsOnlineToRewardConditions < ActiveRecord::Migration[6.0]
  def change
    change_table :reward_conditions, bulk: true do |t|
      t.boolean :is_online, default: false, null: false
    end
    RewardCondition.update_all(is_online: true)
  end
end
