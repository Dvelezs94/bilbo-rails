class BoardPhoto < ApplicationRecord
  include ContentUploader::Attachment(:image)
end
