FactoryBot.define do
  factory :team do

    name        { Faker::Movies::StarWars.planet }
    short_name  { Faker::Movies::StarWars.droid }

  end
end
