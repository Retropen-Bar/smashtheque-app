class RewardConditionDecorator < BaseDecorator
  def name
    "Condition ##{id}"
  end

  def self.rank_value_name(rank)
    "Top #{rank}"
  end

  def rank_name
    self.class.rank_value_name(model.rank)
  end

  def met_reward_conditions_count
    met_reward_conditions.count
  end
end
