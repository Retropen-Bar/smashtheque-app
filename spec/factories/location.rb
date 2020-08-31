FactoryBot.define do
  factory :location do

    icon  { '👍' }
    type  { [Locations::City, Locations::Country].sample.to_s }
    name  { Faker::Address.unique.city }

  end
end
