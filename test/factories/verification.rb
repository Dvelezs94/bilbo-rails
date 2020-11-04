FactoryBot.define do
    factory :verification do
      user {}
      status {}
      password { 'password' }
      password_confirmation { 'password' }
      roles { "user" }
      project_name { name }
    end
  end
  