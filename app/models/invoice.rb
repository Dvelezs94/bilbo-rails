class Invoice < ApplicationRecord
  belongs_to :payment
  belongs_to :user
  validates :invoice_number, uniqueness: true
  after_create :set_invoice_numeber

  def set_invoice_number
    self.update_attribute(:invoice_number, 'BB' + Time.now.year + '%.4d' % id)
  end
end
