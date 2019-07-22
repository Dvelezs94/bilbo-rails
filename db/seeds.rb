# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if ENV.fetch("RAILS_ENV") != "production"
  20.times do |x|
    User.create! do |user|
      user.name = Faker::Name.first_name
      user.email = Faker::Internet.email + "#{x}"
      user.company_name = Faker::Company.name
      user.password = "1234aA"
      puts "#{user.email} - #{user.company_name}"
    end
  end

  100.times do |x|
    Board.create! do |board|
      board.user_id = Faker::Number.between(1, 19)
      board.latitude = Faker::Address.latitude
      board.longitude = Faker::Address.longitude
      board.avg_daily_views = Faker::Number.number(6)
      board.width = "#{Faker::Number.between(10, 14)}.#{Faker::Number.between(30, 90)}".to_f
      board.height = "#{Faker::Number.between(7, 9)}.#{Faker::Number.between(30, 90)}".to_f
      board.duration = Faker::Number.within(7..10)
      board.status = Faker::Number.between(0, 2)
      board.face = Faker::Number.between(0, 3)
    end
  end
end
