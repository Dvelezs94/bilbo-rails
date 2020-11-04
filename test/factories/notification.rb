FactoryBot.define do
  factory :notification do
    recipient factory: :project
    actor factory: :project
  end
end
