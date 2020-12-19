class RewardConditionDecorator < BaseDecorator

  def name
    "Condition ##{id}"
  end

  def self.level_value_color(level)
    RecurringTournamentDecorator::LEVEL_COLORS[level.to_sym]
  end
  def level_color
    self.class.level_value_color(model.level)
  end

  def self.level_value_text(level)
    RecurringTournament.human_attribute_name("level.#{level}")
  end
  def level_text
    self.class.level_value_text(model.level)
  end

  def self.rank_value_name(rank)
    "Top #{rank}"
  end
  def rank_name
    self.class.rank_value_name(model.rank)
  end

end
