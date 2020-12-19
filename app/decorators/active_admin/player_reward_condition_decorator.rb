class ActiveAdmin::PlayerRewardConditionDecorator < PlayerRewardConditionDecorator
  include ActiveAdmin::BaseDecorator

  decorates :player_reward_condition

  def player_admin_link(options = {})
    model.player&.admin_decorate&.admin_link(options)
  end

  def tournament_event_admin_link(options = {})
    model.tournament_event&.admin_decorate&.admin_link(options)
  end

  def reward_condition_admin_link(options = {})
    model.reward_condition&.admin_decorate&.admin_link(options)
  end

  def reward_admin_link(options = {})
    model.reward&.admin_decorate&.admin_link(options)
  end

end
