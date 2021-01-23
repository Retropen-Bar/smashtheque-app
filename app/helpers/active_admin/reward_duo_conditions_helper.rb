module ActiveAdmin::RewardDuoConditionsHelper

  def reward_duo_condition_reward_select_collection
    Reward.order(:name).map do |reward|
      [
        reward.name,
        reward.id
      ]
    end
  end

  def reward_duo_condition_rank_select_collection
    RewardDuoCondition::RANKS.map do |v|
      [
        RewardDuoConditionDecorator.rank_value_name(v),
        v
      ]
    end
  end

end
