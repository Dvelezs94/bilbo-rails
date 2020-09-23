class Shortener < ApplicationRecord
  if !Rails.env.development?
    URL_REGEXP = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
    validates :target_url, format: { with: URL_REGEXP, multiline: true, message: 'You provided invalid URL' }
  end
  before_save :generate_token, :if => :new_record?
  validates_uniqueness_of :token

  private
  def generate_token
    self.token = SecureRandom.hex(4).first(7)
  end
end
