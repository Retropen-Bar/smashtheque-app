FactoryBot.define do
  factory :user do

    name { Faker::Name.unique.name + ' ë€' }

  end
end
