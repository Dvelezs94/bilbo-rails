class Bilbo < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :campaigns
  has_many :prints
end
