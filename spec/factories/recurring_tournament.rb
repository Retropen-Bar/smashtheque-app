FactoryBot.define do
  factory :recurring_tournament do

    level           { RecurringTournament::LEVELS.sample }
    name            { Faker::Movies::StarWars.planet }
    recurring_type  { RecurringTournament::RECURRING_TYPES.sample }
    wday            { (0..6).to_a.sample }

  end
end
