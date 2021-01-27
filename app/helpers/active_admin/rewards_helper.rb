module ActiveAdmin::RewardsHelper

  def reward_category_select_collection
    Reward::CATEGORIES.map do |v|
      [
        Reward.human_attribute_name("category.#{v}"),
        v
      ]
    end
  end

end
