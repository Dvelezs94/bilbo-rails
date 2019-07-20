class Campaign < ApplicationRecord
  belongs_to :user
  has_many :prints
  has_and_belongs_to_many :bilbos
  has_and_belongs_to_many :ads
end
