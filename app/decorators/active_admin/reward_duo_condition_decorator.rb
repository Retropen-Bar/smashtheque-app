class ActiveAdmin::RewardDuoConditionDecorator < RewardDuoConditionDecorator
  include ActiveAdmin::BaseDecorator

  decorates :reward_duo_condition

  def reward_admin_link(options = {}, badge_options = {})
    model.reward&.admin_decorate&.admin_link(options, badge_options)
  end

  def duo_reward_duo_conditions_admin_path
    admin_duo_reward_duo_conditions_path(
      q: {
        reward_duo_condition_id_in: [model.id]
      }
    )
  end

  def duo_reward_duo_conditions_admin_link
    h.link_to duo_reward_duo_conditions_count, duo_reward_duo_conditions_admin_path
  end

end
