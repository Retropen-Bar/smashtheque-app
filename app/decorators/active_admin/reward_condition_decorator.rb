class ActiveAdmin::RewardConditionDecorator < RewardConditionDecorator
  include ActiveAdmin::BaseDecorator

  decorates :reward_condition

  def reward_admin_link(options = {}, badge_options = {})
    model.reward&.admin_decorate&.admin_link(options, badge_options)
  end

  def player_reward_conditions_admin_path
    admin_player_reward_conditions_path(
      q: {
        reward_condition_id_in: [model.id]
      }
    )
  end

  def player_reward_conditions_admin_link
    h.link_to player_reward_conditions_count, player_reward_conditions_admin_path
  end

end
