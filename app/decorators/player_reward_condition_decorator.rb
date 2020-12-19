class PlayerRewardConditionDecorator < BaseDecorator

  def reward_badge
    reward&.decorate&.badge
  end

end
