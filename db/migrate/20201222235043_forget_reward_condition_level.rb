class ForgetRewardConditionLevel < ActiveRecord::Migration[6.0]
  def change
    remove_column :reward_conditions, :level
  end
end
