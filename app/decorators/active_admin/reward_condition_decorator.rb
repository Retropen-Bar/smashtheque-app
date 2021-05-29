module ActiveAdmin
  class RewardConditionDecorator < RewardConditionDecorator
    include ActiveAdmin::BaseDecorator

    decorates :reward_condition

    def reward_admin_link(options = {}, badge_options = {})
      model.reward&.admin_decorate&.admin_link(options, badge_options)
    end

    def met_reward_conditions_admin_path
      admin_met_reward_conditions_path(
        q: {
          reward_condition_id_in: [model.id]
        }
      )
    end

    def met_reward_conditions_admin_link
      h.link_to met_reward_conditions_count, met_reward_conditions_admin_path
    end
  end
end
