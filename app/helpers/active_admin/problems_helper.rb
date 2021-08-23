module ActiveAdmin
  module ProblemsHelper
    def problem_recurring_tournament_select_collection
      RecurringTournament.order('LOWER(name)').pluck(:name, :id)
    end

    def problem_nature_select_collection
      Problem::NATURE_GROUPS.map do |key, values|
        [
          Problem.human_attribute_name("nature.#{key}"),
          values.map do |value|
            full_value = "#{key}__#{value}"
            [
              Problem.human_attribute_name("nature.#{full_value}"),
              full_value
            ]
          end
        ]
      end
    end

    def problem_existing_reporting_users_collection
      User.with_reported_problems.order('LOWER(name)').pluck(:name, :id)
    end

    def problem_existing_players_collection
      Player.with_problems.order('LOWER(name)').pluck(:name, :id)
    end

    def problem_existing_duos_collection
      Duo.with_problems.order('LOWER(name)').pluck(:name, :id)
    end
  end
end
