# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if ENV.fetch("RAILS_ENV") != "production"

  5.times do |x|
    User.create! do |provider|
      provider.name = Faker::Name.first_name
      provider.email = "provider#{x}@bilbo.mx"
      provider.password = "1234aA"
      provider.role = :provider
      provider.project_name = Faker::Company.name
      provider.confirmed_at = DateTime.now
      provider.save
      puts provider.email
      10.times do
        lat = Faker::Address.latitude
        lng = Faker::Address.longitude
        4.times do |y|
          provider.projects.first.boards.create! do |board|
            board.lat = lat
            board.lng = lng
            board.avg_daily_views = Faker::Number.number(digits: 6)
            board.width = "#{Faker::Number.between(from: 10, to: 14)}.#{Faker::Number.between(from: 30, to: 90)}".to_f
            board.height = "#{Faker::Number.between(from: 7, to: 9)}.#{Faker::Number.between(from: 30, to: 90)}".to_f
            board.duration = Faker::Number.within(range: 7..10)
            board.status = Faker::Number.between(from: 0, to: 1)
            board.face = ["north", "south", "east", "west"].sample
            board.name = "#{x}#{y}#{Faker::Lorem.sentence}"
            board.address = Faker::Address.full_address
            board.category = ["television", "billboard", "wallboard"].sample
            board.base_earnings = Faker::Number.between(from: 40000, to: 200000)
            board.social_class = Faker::Number.between(from: 0, to: 3)
            board.start_time = Time.now
            board.end_time = Time.now + rand(-300..480).minutes
            board.utc_offset = rand(-300..0)
          end
        end
      end
    end
  end

  2.times do |x|
    User.create! do |user|
      user.name = Faker::Name.first_name
      user.email = "user#{x}@bilbo.mx"
      user.password = "1234aA"
      user.project_name = Faker::Company.name
      user.confirmed_at = DateTime.now
      user.balance = Faker::Number.between(from: 500, to: 5000)
      puts user.email
      user.save
      10.times do |y|
        user.projects.first.ads.new do |ad|
          ad.name = "ad #{y}"
          ad.multimedia.attach(io: File.open('app/assets/images/placeholder_active_storage.png'), filename: 'avatar.png', content_type: 'image/png')
          ad.save
          1.times do |z|
            ad.campaigns.new do |cp|
              cp.name    = "#{Faker::Company.name} #{Faker::Commerce.product_name}"
              cp.budget  = Faker::Number.between(from: 5, to: 50)
              cp.state   = Faker::Boolean.boolean
              cp.status  = Faker::Number.between(from: 0, to: 1)
              cp.project = ad.project
              cp.boards  = Board.order('RANDOM()').first(Faker::Number.between(from: 2, to: 7))
              cp.board_campaigns.update(status: Faker::Number.between(from: 0, to: 3))
            end
          end
        end
      end
    end
  end

  puts "Creating impressions.. It may take minutes to finish"
  Campaign.all.each do |cp|
    puts "#{cp.id} out of #{Campaign.count}..."
    cp.boards.each do |board|
      rand(*100).times do
        board.impressions.create! do |im|
          im.campaign = cp
          im.created_at = (rand*365).days.ago
          im.api_token = board.api_token
        end
      end
    end
  end

  User.create! do |user|
    user.name = "Admin"
    user.email = "admin@bilbo.mx"
    user.password = "1234aA"
    user.role = :admin
    user.confirmed_at = DateTime.now
    puts "#{user.email}"
  end
end
