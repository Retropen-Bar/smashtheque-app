module ActiveAdmin
  module RewardConditionsHelper
    def reward_condition_reward_select_collection
      Reward.ordered_by_level.map do |reward|
        [
          reward.decorate.name,
          reward.id
        ]
      end
    end

    def reward_condition_rank_select_collection
      RewardCondition::RANKS.map do |v|
        [
          RewardConditionDecorator.rank_value_name(v),
          v
        ]
      end
    end
  end
end
