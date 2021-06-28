class MetRewardConditionDecorator < BaseDecorator
  def reward_badge(options = {})
    reward_condition.decorate.reward_badge(options)
  end
end
