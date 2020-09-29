FactoryBot.define do
  factory :ad do
    name { Faker::Company.name }
    description { Faker::Lorem.sentence }
    project {}
  end
end
