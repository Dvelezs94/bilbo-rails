class Ad < ApplicationRecord
  belongs_to :user
  has_many :campaigns
  has_many_attached :multimedia

  validates :name, presence: true

  validates :multimedia, content_type: ["image/png", "image/jpeg", "image/gif"]
end
