class MetRewardConditionDecorator < BaseDecorator
  def reward_badge(options = {})
    reward_condition.decorate.reward_badge(options)
  end
  
  def points_count(size, options = {})
    awarded.decorate.points_count(size, options)
  end
end
