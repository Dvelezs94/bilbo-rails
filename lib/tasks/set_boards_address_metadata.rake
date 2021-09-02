namespace :set_boards_address_metadata do
    desc "sets address metadata"
    task :set => :environment do
      Board.where(country: nil).each do |board|
        res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode [board.lat, board.lng]
        country = res.country
        country_state = res.state_name
        city = res.city
        postal_code = res.zip
        name = board.name
        board.update(country: country, country_state: country_state, city: city, postal_code: postal_code, name: name)
        puts "finished updating #{name} with id #{board.id}"
      end
    end
  end
  