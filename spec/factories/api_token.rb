FactoryBot.define do
  factory :api_token do

    name  { Faker::Movies::StarWars.planet }

  end
end
