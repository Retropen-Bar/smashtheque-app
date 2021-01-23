class RewardDuoConditionDecorator < BaseDecorator

  def name
    "Condition ##{id}"
  end

  def self.rank_value_name(rank)
    "Top #{rank}"
  end
  def rank_name
    self.class.rank_value_name(model.rank)
  end

  def duo_reward_duo_conditions_count
    duo_reward_duo_conditions.count
  end

end
