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

  def reward_duo_conditions_admin_path
    admin_reward_duo_conditions_path(q: { reward_id_in: [model.id] })
  end

  def reward_duo_conditions_admin_link
    h.link_to reward_duo_conditions_count, reward_duo_conditions_admin_path
  end

  def conditions_admin_path
    h.polymorphic_path(
      [:admin, conditions_name],
      q: { reward_id_in: [model.id] }
    )
  end

  def conditions_admin_link
    h.link_to conditions_count, conditions_admin_path
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

  def duo_reward_duo_conditions_admin_path
    admin_duo_reward_duo_conditions_path(
      q: {
        reward_duo_condition_reward_id_in: [model.id]
      }
    )
  end

  def duo_reward_duo_conditions_admin_link
    h.link_to duo_reward_duo_conditions_count, duo_reward_duo_conditions_admin_path
  end

  def met_conditions_admin_path
    h.polymorphic_path(
      [:admin, met_conditions_name],
      q: {
        "#{condition_name}_reward_id_in" => [model.id]
      }
    )
  end

  def met_conditions_admin_link
    h.link_to met_conditions_count, met_conditions_admin_path
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

  def duos_admin_path
    admin_duos_path(
      q: {
        rewards_id_in: [model.id]
      }
    )
  end

  def duos_admin_link
    h.link_to duos_count, duos_admin_path
  end

  def awardeds_admin_path
    h.polymorphic_path(
      [:admin, awardeds_name],
      q: {
        rewards_id_in: [model.id]
      }
    )
  end

  def awardeds_admin_link
    h.link_to awardeds_count, awardeds_admin_path
  end

  def category_status
    return nil if category.blank?
    arbre do
      status_tag category_name, class: CATEGORY_COLORS[category.to_sym]
    end
  end

end
