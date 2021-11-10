class BoardMapPhoto < ApplicationRecord
  belongs_to :board
  belongs_to :map_photo
  after_destroy :delete_unused_photos

  def delete_unused_photos
    DeleteUnusedPhotosWorker.perform_at(5.seconds.from_now)
  end
end
