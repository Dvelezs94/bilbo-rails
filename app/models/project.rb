class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates_presence_of :name

  has_many :project_users
  has_many :users, through: :project_users
  has_many :campaigns
  has_many :ads
end
