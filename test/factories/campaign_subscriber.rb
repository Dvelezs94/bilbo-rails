FactoryBot.define do
    factory :campaign_subscriber do
      name { Faker::Name.name  }
      phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
      campaign {}
      dont_send_sms { true }
    end
  end
