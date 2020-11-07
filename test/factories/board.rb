FactoryBot.define do
    factory :board do
        project {}
        name { Faker::Company.name }
        lat { Faker::Address.latitude}
        lng {Faker::Address.longitude}
        avg_daily_views {Faker::Number.between(from: 10000, to:800000 )}
        width {"1280"}
        height {"720"}
        address {Faker::Address.full_address_as_hash(:full_address)}
        category{"A"}
        base_earnings {"100000"}
        face {Faker::Compass.direction}
    end
  end

  