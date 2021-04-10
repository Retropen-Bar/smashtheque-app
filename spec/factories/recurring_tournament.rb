FactoryBot.define do
  factory :recurring_tournament do

    level           { RecurringTournament::LEVELS.sample }
    name            { Faker::Movies::StarWars.planet }
    recurring_type  { RecurringTournament::RECURRING_TYPES.sample }
    wday            { (0..6).to_a.sample }
    starts_at_hour  { (0..23).to_a.sample }
    starts_at_min  { (0..59).to_a.sample }

  end
end
