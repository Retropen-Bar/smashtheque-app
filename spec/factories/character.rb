FactoryBot.define do
  factory :character do

    icon  { Faker::Movies::StarWars.planet }
    name  { Faker::Movies::StarWars.unique.droid }
    emoji { SecureRandom.hex }

  end
end
