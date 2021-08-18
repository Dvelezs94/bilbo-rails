FactoryBot.define do
    factory :campaign do
      name { Faker::Name.name }
      description { "He is one of the main combat specialists of the Straw Hat Pirates".downcase }
      starts_at {Faker::Date.between(from: 30.days.ago, to: 0.days.ago)}
      ends_at   {Faker::Date.between(from: 1.day.from_now, to: 8.days.from_now)}
      budget  {Faker::Number.between(from: 50, to: 200)}
      state   {Faker::Boolean.boolean}
      status  {Faker::Number.between(from: 0, to: 1)}
      boards  {Board.order('RANDOM()').first(Faker::Number.between(from: 2, to: 7))}
      objective { 0 }
      project {}
      provider_campaign {false}
    end
  end
