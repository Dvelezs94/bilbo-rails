FactoryBot.define do
  factory :impression do
    uuid {Faker::Alphanumeric.alpha(number: 15)}
    duration {10}
  end
end
