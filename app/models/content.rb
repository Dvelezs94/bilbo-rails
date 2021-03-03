class Content < ApplicationRecord
  belongs_to :project
  mount_uploader :multimedia, ContentUploader
end
