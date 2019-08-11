class Invoice < ApplicationRecord
  belongs_to :payment
  belongs_to :user
end
