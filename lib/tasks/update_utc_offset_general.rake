namespace :update_utc_offset_general do
  desc "Update utc offset of boards based on their latitute and longitude"

  # Configure the geonames api for the timezone gem
  Timezone::Lookup.config(:geonames) do |c|
    c.username = 'carlos0914' # <-- username for geonames.org
    c.offset_etc_zones = true
  end
  # bilbo run rails update_utc_offset_general:do_it
  task :do_it => :environment do
    p "Updating utc_offset of all boards"

    Board.all.each do |b|
      if b.lat.nil? or b.lng.nil? #Get coordinates of the board in case they aren't already stored
        loc = Geokit::Geocoders::GoogleGeocoder.geocode(b.address)
        b.update(lat: loc.lat,lng: lon.lng)
      end
      timezone = Timezone.lookup(b.lat, b.lng) #Get the timezone of the board by it's coordinates
      offset = timezone.utc_offset / 60 #Utc offset given by the Timezone gem is in seconds, so we convert them to minutes
      b.update(utc_offset: offset)
    end

    p "The utc_offset of all boards has been updated"
  end

end
