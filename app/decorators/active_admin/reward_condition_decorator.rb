class ActiveAdmin::RewardConditionDecorator < RewardConditionDecorator
  include ActiveAdmin::BaseDecorator

  decorates :reward_condition

  def level_status
    arbre do
      status_tag level_text, class: level_color
    end
  end

  def reward_admin_link(options = {})
    model.reward&.admin_decorate&.admin_link(options)
  end

end
