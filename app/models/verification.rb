class Verification < ApplicationRecord
  belongs_to :user

  enum status: { pending: 0, accepted: 1, denied: 2 }

  has_one_attached :official_id
  validates :official_id, content_type: ["image/png", "image/jpeg", "image/jpg"]
  validates_presence_of :name, :user_id, :official_id, :business_name, :street_1, :city, :state, :zip_code, :business_code, :official_business_name, :phone

  def full_address
    "#{self.street_1} #{self.street_2} #{self.zip_code}. #{self.city} #{self.state}, #{self.country}"
  end
end
