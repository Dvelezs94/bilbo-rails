class Board < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :campaigns
  has_many :prints
  has_many_attached :images
  enum status: { enabled: 0, disabled: 1, banned: 2}
  enum face: {
    north: 0,
    south: 1,
    east: 2,
    west: 3
  }

  # function to get only 1 marker per position, otherwise markercluster displays a cluster marker in the position
  # and the user is not able to click the marker because it is a cluster
  def self.get_map_markers
    self.enabled.select(:lat, :lng).as_json(:except => :id).uniq
  end
end
