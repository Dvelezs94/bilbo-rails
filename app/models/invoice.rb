class Invoice < ApplicationRecord
  belongs_to :payment
  belongs_to :user
  validates :invoice_number, uniqueness: { scope: :user }
  before_validation :set_invoice_number


  private

  def set_invoice_number
    self.invoice_number = ("BB#{Time.now.to_i}")
  end
end
