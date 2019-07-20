class Ad < ApplicationRecord
  belongs_to :artwork
  enum status: { pending: 0, accepted: 1, declined: 2}
end
