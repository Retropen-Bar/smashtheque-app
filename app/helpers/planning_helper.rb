module PlanningHelper

  def planning_level_select_collection
    RecurringTournament::LEVELS.map do |v|
      [
        RecurringTournament.human_attribute_name("level.#{v}"),
        v
      ]
    end
  end

end
