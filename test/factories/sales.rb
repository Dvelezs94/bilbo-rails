FactoryBot.define do
  factory :sale do
    percent { 20 }
    starts_at { "2020-11-07 21:12:39" }
    ends_at { "2020-11-07 21:12:39" }
    board_ids { [1,2] }
    description { "My new Sale" }
  end
end
