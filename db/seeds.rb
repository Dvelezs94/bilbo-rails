# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if ENV.fetch("RAILS_ENV") != "production"
  User.create! do |user|
    user.name = "Admin"
    user.email = "admin@bilbo.mx"
    user.password = "1234aA"
    user.role = :admin
    user.confirmed_at = DateTime.now
    puts "#{user.email}"
  end
  5.times do |x|
    User.new do |provider|
      provider.name = Faker::Name.first_name
      provider.email = "provider#{x}@bilbo.mx"
      provider.password = "1234aA"
      provider.role = :provider
      provider.project_name = "provider#{x}"
      provider.confirmed_at = DateTime.now
      provider.save
      puts provider.email
      10.times do
        lat = Faker::Address.latitude
        lng = Faker::Address.longitude
        4.times do |y|
          loc = Geokit::Geocoders::GoogleGeocoder.reverse_geocode("#{rand(21.8..22.0)},#{rand(-102.4..-102.3)}")
          provider_earnings = Faker::Number.between(from: 40000, to: 200000)
          provider.projects.first.boards.new do |board|
            board.lat = loc.lat
            board.lng = loc.lng
            board.avg_daily_views = Faker::Number.number(digits: 6)
            board.width = "#{Faker::Number.between(from: 10, to: 14)}.#{Faker::Number.between(from: 30, to: 90)}".to_f
            board.height = "#{Faker::Number.between(from: 7, to: 9)}.#{Faker::Number.between(from: 30, to: 90)}".to_f
            board.duration = Faker::Number.within(range: 7..10)
            board.status = Faker::Number.between(from: 0, to: 1)
            board.face = ["north", "south", "east", "west"].sample
            board.name = "#{y}#{Faker::Lorem.sentence}"
            board.address = Faker::Address.full_address
            board.category = ["television", "billboard", "wallboard"].sample
            board.base_earnings = provider_earnings * 1.25
            board.provider_earnings = provider_earnings
            board.social_class = Faker::Number.between(from: 0, to: 3)
            board.start_time = Time.now
            board.images_only = Faker::Boolean.boolean(true_ratio: 0.5)
            board.end_time = Time.now + rand(-300..480).minutes
            board.utc_offset = rand(-300..0)
            board.default_images.attach(io: File.open('app/assets/images/placeholder_active_storage.png'), filename: 'placeholder.png', content_type: 'image/png')
            board.smart = Faker::Boolean.boolean
            board.save
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
      user.project_name = "user#{x}"
      user.confirmed_at = DateTime.now
      user.balance = Faker::Number.between(from: 500, to: 5000)
      puts user.email
      user.save
      1.times do |y|
        user.payments.create! do |payment|
          payment.total     = Faker::Number.between(from: 100, to: 5000)
          payment.paid_with = "SPEI"
          payment.status    = Faker::Number.between(from: 0, to: 4)
          payment.spei_reference = Faker::Lorem.characters(number: 10)
          payment.transaction_fee = 0
        end
      end
      10.times do |y|
        Campaign.create! do |cp|
          cp.name    = "#{Faker::Company.name} #{Faker::Commerce.product_name}"
          cp.budget  = Faker::Number.between(from: 500, to: 5000)
          cp.status  = Faker::Number.between(from: 0, to: 1)
          dist = (1..Board.count).to_a.sample(Faker::Number.between(from: 2, to: 7)).map{|id| ["#{id}", "#{Faker::Number.between(from: 500, to:5000)}"]}.to_h
          cp.budget_distribution = dist.to_json
          cp.boards  = Board.where(id: dist.keys)
          cp.project = user.projects.first
          cp.provider_campaign = false
          cp.starts_at = (rand*365).days.ago.beginning_of_day
          cp.ends_at = cp.starts_at + (rand*30 + 1).to_i.days
          cp.state   = Faker::Boolean.boolean
        end
      end
    end
  end
  BoardsCampaigns.all.each do |bc|
    bc.update(status: Faker::Number.between(from: 0, to: 2))
  end
  puts "Creating impressions.. It may take minutes to finish"
  Campaign.all.each do |cp|
    puts "#{cp.id} out of #{Campaign.count}..."
    cp.boards.each do |board|
      rand(*100).times do
        board.impressions.create! do |im|
          im.campaign = cp
          im.uuid = Faker::Alphanumeric.alpha(number: 15)
          im.created_at = (rand*365).days.ago
          im.api_token = board.api_token
          im.duration = cp.duration
        end
      end
    end
  end
end
