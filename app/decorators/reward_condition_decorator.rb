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

  def badge_tooltip
    [
      "Top #{rank} #{online? ? 'online' : 'offline'}",
      "#{size_min} à #{size_max} joueurs"
    ].join('<br/>')
  end

  def reward_badge(options = {})
    return nil unless reward

    reward.decorate.badge({ tooltip: badge_tooltip }.merge(options))
  end
end
