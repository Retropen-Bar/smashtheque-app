module ActiveAdmin
  module HasTrackRecordsDecorator
    def unique_rewards_admin_links(options = {}, badge_options = {})
      unique_rewards.ordered_by_level.admin_decorate.map do |reward|
        reward.admin_link(options, badge_options.clone)
      end
    end

    def best_reward_admin_link(options = {}, badge_options = {})
      best_reward&.admin_decorate&.admin_link(options, badge_options.clone)
    end

    def best_rewards_admin_links(options = {}, badge_options = {})
      best_rewards.map do |reward|
        reward.admin_decorate.admin_link(options, badge_options.clone)
      end
    end

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
