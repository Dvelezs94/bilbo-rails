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
        provider_earnings { (base_earnings * 0.80) }
        face {Faker::Compass.direction}
        start_time {Time.zone.now.beginning_of_day + 8.hours}
        end_time {Time.zone.now.beginning_of_day + 22.hours}
        steps{false}
        multiplier{nil}
    end
  end
