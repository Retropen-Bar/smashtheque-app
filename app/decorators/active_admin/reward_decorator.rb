class ActiveAdmin::RewardDecorator < RewardDecorator
  include ActiveAdmin::BaseDecorator

  CATEGORY_COLORS = {
    Reward::CATEGORY_ONLINE_1V1.to_sym => :green,
    Reward::CATEGORY_ONLINE_2V2.to_sym => :blue
  }.freeze

  decorates :reward

  def admin_link(options = {}, badge_options = {})
    super(options.merge(label: badge(badge_options)))
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

  def players_admin_path
    admin_players_path(
      q: {
        rewards_id_in: [model.id]
      }
    )
  end

  def players_admin_link
    h.link_to players_count, players_admin_path
  end

  def category_status
    return nil if category.blank?
    arbre do
      status_tag category_name, class: CATEGORY_COLORS[category.to_sym]
    end
  end

end
