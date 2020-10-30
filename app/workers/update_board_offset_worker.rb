class UpdateBoardOffsetWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    # Configure the geonames api for the timezone gem
    Timezone::Lookup.config(:geonames) do |c|
      #c.username = ENV.fetch("GEONAMES_USER") {"carlos0914"} # <-- username for geonames.org
      c.username = 'carlos0914'
      c.offset_etc_zones = true
    end
    #Note: The google api can also be used here, some people use the
    #google api when geonames fails or reaches the credit limit
    Board.all.each do |b|
      tz = Timezone.lookup(b.lat, b.lng) #Get the timezone of the board by it's coordinates
      offset = tz.utc_offset / 60 #Utc offset given by the Timezone gem is in seconds, so we convert them to minutes
      if offset != b.utc_offset
        b.update(utc_offset: offset)
      end
    end
  end
end
