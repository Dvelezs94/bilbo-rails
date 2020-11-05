FactoryBot.define do
    factory :project_user do
      user {}
      email {"#{name}@bilbo.mx".downcase}
      project{}
    end
  end