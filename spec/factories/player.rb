FactoryBot.define do
  factory :player do

    name  { Faker::Name.unique.name }

  end
end
