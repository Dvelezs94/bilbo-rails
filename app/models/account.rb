class Account < ApplicationRecord
  extend FriendlyId
  validates_presence_of :subdomain
  friendly_id :subdomain, use: :slugged
  belongs_to :user
  has_many :campaigns
  has_many :ads
end
