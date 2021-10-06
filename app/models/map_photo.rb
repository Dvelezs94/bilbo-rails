class MapPhoto < ApplicationRecord
  include ContentUploader::Attachment(:image)

  has_many :board_map_photos, dependent: :delete_all

  def delete_if_not_in_use
    # After deleting a BoardMapPhoto object, check if there is any other object of the same class using
    # the same MapPhoto, and if it does, keep the photo (do nothing), or else delete the MapPhoto
    if !BoardMapPhoto.where(map_photo: self).present?
      self.delete
    end
  end
end
