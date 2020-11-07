FactoryBot.define do
    factory :report do
      name { Faker::Company.name }
      project {}
      attachment{}
    end
  end