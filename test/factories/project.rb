FactoryBot.define do
  factory :project do
    name { "Dragon Ball Z" }
      trait :enabled do
        status {:enabled}
    end
  end
end
