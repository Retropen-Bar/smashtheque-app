module ActiveAdmin
  class MetRewardConditionDecorator < MetRewardConditionDecorator
    include ActiveAdmin::BaseDecorator

    decorates :met_reward_condition

    def record_admin_link(options = {})
      model.record&.admin_decorate&.admin_link(options)
    end

    def event_admin_link(options = {})
      model.event&.admin_decorate&.admin_link(options)
    end

    def reward_condition_admin_link(options = {})
      model.reward_condition&.admin_decorate&.admin_link(options)
    end

    def reward_admin_link(options = {})
      model.reward&.admin_decorate&.admin_link(options)
    end
  end
end
