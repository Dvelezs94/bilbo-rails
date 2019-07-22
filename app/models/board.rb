class Board < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :campaigns
  has_many :prints
  enum status: { enabled: 0, disabled: 1, banned: 2}
  enum face: {
    north: 0,
    south: 1,
    east: 2,
    west: 3
  }
end
