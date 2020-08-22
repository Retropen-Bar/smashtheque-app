FactoryBot.define do
  factory :player do

    name  { Faker::Movies::HarryPotter.character }

  end
end
