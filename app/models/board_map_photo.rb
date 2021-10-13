class BoardMapPhoto < ApplicationRecord
  belongs_to :board
  belongs_to :map_photo

  def destroy
    photo_id = self.map_photo_id
    if self.delete
      if BoardMapPhoto.where(map_photo_id: photo_id).count == 0
        MapPhoto.find(photo_id).delete
      end
    end
  end
end
