class Campaign < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :bilbos
  has_one :ad
end
