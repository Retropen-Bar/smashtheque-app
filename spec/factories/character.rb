FactoryBot.define do
  factory :character do

    icon  { Faker::Movies::StarWars.planet }
    name  { [Faker::Games::SuperSmashBros.fighter, Faker::Number.number].join(' ') }
    emoji { SecureRandom.hex }

  end
end
