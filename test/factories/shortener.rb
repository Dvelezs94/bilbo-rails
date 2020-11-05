FactoryBot.define do
    factory :shortener do
      target_url {Faker::Internet.url}
      token {}
    end
  end