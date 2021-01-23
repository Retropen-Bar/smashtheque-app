class ActiveAdmin::DuoDecorator < DuoDecorator
  include ActiveAdmin::BaseDecorator

  decorates :duo

  def player1_admin_link(options = {})
    player1&.admin_decorate&.admin_link(options)
  end

  def player2_admin_link(options = {})
    player2&.admin_decorate&.admin_link(options)
  end

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

  def reward_duo_reward_duo_conditions_admin_path(reward)
    admin_duo_reward_duo_conditions_path(
      q: {
        player_id_in: [model.id],
        reward_duo_condition_reward_id_in: [reward.id]
      }
    )
  end

end
