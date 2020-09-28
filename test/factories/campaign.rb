FactoryBot.define do
    factory :campaign do
      name { "Roronoa Zoro a.k.a “Pirate Hunter Zoro”" }
      description { "He is one of the main combat specialists of the Straw Hat Pirates".downcase }
      budget  {Faker::Number.between(from: 5, to: 50)}
      state   {Faker::Boolean.boolean}
      status  {Faker::Number.between(from: 0, to: 1)}
      boards  {Board.order('RANDOM()').first(Faker::Number.between(from: 2, to: 7))}
      project {}
    end
  end
  