FactoryBot.define do
    factory :impression_hour do
      imp {Faker::Number.between(from: 1, to: 10)}
      day {"everyday"}
      start{"13:00"}
      campaign{}
    end
  end