class UpdateBoardOffsetWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    Board.all.each do |b|
      if b.lat.nil? or b.lng.nil? #Get coordinates of the board in case they aren't already stored
        p "Latitude or longitude missing for board with id #{b.id}. Updating information..."
        loc = Geokit::Geocoders::GoogleGeocoder.geocode(b.address)
        b.update(lat: loc.lat,lng: loc.lng)
      end

      tz = Timezone.lookup(b.lat, b.lng) #Get the timezone of the board by it's coordinates
      offset = tz.utc_offset / 60 #Utc offset given by the Timezone gem is in seconds, so we convert them to minutes

      b.update(utc_offset: offset)
    end
  end
end
