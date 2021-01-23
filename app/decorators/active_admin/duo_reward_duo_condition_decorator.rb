class ActiveAdmin::DuoRewardDuoConditionDecorator < DuoRewardDuoConditionDecorator
  include ActiveAdmin::BaseDecorator

  decorates :duo_reward_duo_condition

  def duo_admin_link(options = {})
    model.duo&.admin_decorate&.admin_link(options)
  end

  def duo_tournament_event_admin_link(options = {})
    model.duo_tournament_event&.admin_decorate&.admin_link(options)
  end

  def reward_duo_condition_admin_link(options = {})
    model.reward_duo_condition&.admin_decorate&.admin_link(options)
  end

  def reward_admin_link(options = {})
    model.reward&.admin_decorate&.admin_link(options)
  end

end
