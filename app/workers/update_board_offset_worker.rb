class UpdateBoardOffsetWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    Board.all.each do |b|
      tz = Timezone.lookup(b.lat, b.lng) #Get the timezone of the board by it's coordinates
      offset = tz.utc_offset / 60 #Utc offset given by the Timezone gem is in seconds, so we convert them to minutes
      if offset != b.utc_offset
        b.update(utc_offset: offset)
      end
    end
  end
end
