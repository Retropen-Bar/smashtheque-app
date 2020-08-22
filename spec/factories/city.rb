FactoryBot.define do
  factory :city do

    icon  { '👍' }
    name  { Faker::Address.unique.city }

  end
end
