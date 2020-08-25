FactoryBot.define do
  factory :discord_user do

    discord_id { Faker::Number.unique.number(digits: 10).to_s }

  end
end
