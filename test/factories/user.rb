FactoryBot.define do
  factory :user do
    name { "Goku" }
    email { "#{name}@bilbo.mx".downcase }
    password { 'password' }
    password_confirmation { 'password' }
    roles { "user" }
    project_name { name }
  end
end
