class DeleteUnusedPhotosWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    #Remove unused map photos to save space
    MapPhoto.select{|x| x.board_map_photos.count == 0}.each do |mp|
      mp.delete
    end
  end
end
