class MapPhoto < ApplicationRecord
  include ContentUploader::Attachment(:image)

  has_many :board_map_photos, dependent: :delete_all

  def processed?
    image_url(:large).present?
  end
end
