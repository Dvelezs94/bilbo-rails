class Impression < ApplicationRecord
  belongs_to :board
  belongs_to :campaign, optional: true
end
