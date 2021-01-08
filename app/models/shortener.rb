class Shortener < ApplicationRecord
  include Rails.application.routes.url_helpers
  acts_as_punchable

  if !Rails.env.development?
    URL_REGEXP = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
    validates :target_url, format: { with: URL_REGEXP, multiline: true, message: 'You provided invalid URL' }
  end
  before_save :generate_token, :if => :new_record?
  validates_uniqueness_of :token
  after_create :generate_qr_code

  def png_to_text
    Base64.decode64(qr)
  end

  def daily_hits(time_range = 30.days.ago..Time.zone.now)
    punches.unscope(:order).where(starts_at: time_range).group_by_day(:starts_at).count
  end

  private
  def generate_token
    self.token = SecureRandom.hex(4).first(7)
  end

  def generate_qr_code
    require 'rqrcode'

    qrcode = RQRCode::QRCode.new(shorten_url(self.token))

    # NOTE: showing with default options specified explicitly
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 420
    )
    self.update!(qr: Base64.encode64(png.to_s))
  end
end
