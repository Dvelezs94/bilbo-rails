class Artwork < ApplicationRecord
  belongs_to :ads, optional: true
end
