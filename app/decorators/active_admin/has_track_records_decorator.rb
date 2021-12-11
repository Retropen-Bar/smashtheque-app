module ActiveAdmin
  module HasTrackRecordsDecorator
    def reward_met_reward_conditions_admin_path(reward)
      admin_met_reward_conditions_path(
        q: {
          awarded_type_in: [model.class],
          awarded_id_in: [model.id],
          reward_condition_reward_id_in: [reward.id]
        }
      )
    end
  end
end
