class Ad < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :campaigns
  enum status: { pending: 0, accepted: 1, declined: 2}
  has_many_attached :multimedia

  validates :name, presence: true

  validates :multimedia, content_type: ["image/png", "image/jpeg", "image/gif"]
end
