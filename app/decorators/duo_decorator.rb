class DuoDecorator < BaseDecorator

  def name_with_player_names
    "#{name} : #{player1_name} & #{player2_name}"
  end

  def best_rewards_badges(options = {})
    best_rewards.map do |reward|
      reward.decorate.badge(options.clone)
    end
  end

  def unique_rewards_badges(options = {})
    unique_rewards.ordered_by_level.decorate.map do |reward|
      reward.badge(options.clone)
    end
  end

end
