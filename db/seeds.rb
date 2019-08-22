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
      user.email = "user." + Faker::Internet.email + "#{x}"
      user.company_name = Faker::Company.name
      user.password = "1234aA"
      puts "#{user.email}"
    end
  end

  20.times do |x|
    User.create! do |user|
      user.name = Faker::Name.first_name
      user.email = "provider." + Faker::Internet.email + "#{x}"
      user.company_name = Faker::Company.name
      user.password = "1234aA"
      user.role = :provider
      puts "#{user.email}"
    end
  end

  50.times do |x|
    lat = Faker::Address.latitude
    lng = Faker::Address.longitude
    4.times do |b|
      Board.create! do |board|
        # Assign the board to the providers available
        board.user_id = Faker::Number.between(20, 40)
        board.lat = lat
        board.lng = lng
        board.avg_daily_views = Faker::Number.number(6)
        board.width = "#{Faker::Number.between(10, 14)}.#{Faker::Number.between(30, 90)}".to_f
        board.height = "#{Faker::Number.between(7, 9)}.#{Faker::Number.between(30, 90)}".to_f
        board.duration = Faker::Number.within(7..10)
        board.status = Faker::Number.between(0, 1)
        board.face = b
        board.name = Faker::FunnyName.name
        board.address = Faker::Address.full_address
        board.category = ["television", "billboard", "wallboard"].sample
        board.base_earnings = Faker::Number.between(1000, 4000)
      end
      20.times do
        Impression.create! do |pr|
          pr.board_id = (x + 1)
          #pr.campaign_id = (x + 1)
        end
      end
    end
  end
end
