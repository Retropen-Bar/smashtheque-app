FactoryBot.define do
  factory :community do

    name      { Faker::Nation.nationality }
    address   { Faker::Address.city }
    latitude  { Faker::Address.latitude }
    longitude { Faker::Address.longitude }

  end
end
