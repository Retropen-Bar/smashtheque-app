class ActiveAdmin::RewardDecorator < RewardDecorator
  include ActiveAdmin::BaseDecorator

  decorates :reward

  def admin_link(options = {})
    super(options.merge(label: badge))
  end

  def reward_conditions_admin_path
    admin_reward_conditions_path(q: { reward_id_in: [model.id] })
  end

  def reward_conditions_admin_link
    h.link_to reward_conditions_count, reward_conditions_admin_path
  end

  def player_reward_conditions_admin_path
    admin_player_reward_conditions_path(
      q: {
        reward_condition_reward_id_in: [model.id]
      }
    )
  end

  def player_reward_conditions_admin_link
    h.link_to player_reward_conditions_count, player_reward_conditions_admin_path
  end

end
