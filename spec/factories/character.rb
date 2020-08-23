FactoryBot.define do
  factory :character do

    icon  { Faker::Movies::StarWars.planet }
    name  { Faker::Games::SuperSmashBros.unique.fighter }
    emoji { SecureRandom.hex }

  end
end
