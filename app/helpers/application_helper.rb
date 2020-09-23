module ApplicationHelper

  def user_avatar(user, size=40)
    if user.avatar.attached?
      user.avatar.variant(resize: "#{size}x#{size}!")
    else
      gravatar_image_url(user.email, size: size)
    end
  end

  # formats the number as +52-(844) 352-1674
  # the input should be a 12 digit phone without special chars, like 528443521674
  def phone_formatter(phone)
    # remove the + from the phone number
    if phone.include? "+"
      phone = phone.scan(/\d/).join('')
    end
    number_to_phone(phone.last(10), country_code: phone.first(2))
  end

  def url_from_media(media)
    if Rails.env.production?
      "https://#{ENV.fetch('CDN_HOST')}/#{media.blob.key}"
    else
      url_for(media)
    end
  end
  # standard way to format times
  def format_time(time)
    l(time, format: "%B %d %Y, %-I:%M %p")
  end

  def number_to_currency_credit(number, precision = 2)
    number_to_currency(number, precision: precision, separator: ".", delimiter: ",", format: "%n", unit: "")
  end

  def number_to_currency_usd(number)
    number_to_currency(number, precision: 2, separator: ".", unit: "$", delimiter: ",", format: "%u %n")
  end

  # round number to
  def up_to_nearest_5(n)
    return n if n % 5 == 0
    rounded = n.round(-1)
    rounded > n ? rounded : rounded + 5
  end

  def payment_fee(subtotal)
    # https://www.paypal.com/businesswallet/classic-fees
    # percentage paypal charges per transaction
    paypal_percentage_fee = 4.58
    # amount in MXN of the flat fee
    paypal_flat_fee = 4.64

    return (((100 * (subtotal + paypal_flat_fee)) / (100 - paypal_percentage_fee)) - subtotal).round(3)
  end

  def get_image_size_from_metadata(image)
    begin
      if image.metadata[:height].present?
        image.metadata
      else
        ActiveStorage::Analyzer::ImageAnalyzer.new(image).metadata
      end
    # this is a fix for images that cannot be analyzed, like webp images
    rescue
      meta = {}
      meta[:height] = 0
      meta[:width] = 0
      meta
    end
  end

  # remove non valid characters for SMS like ñ, á, etc... and replace with similar
  # versions like ñ => n, á => a, etc..
  def convert_message_to_sms_format(msg)
    return I18n.transliterate("[Bilbo]#{msg}")
  end

  def send_sms(phone_number, message)
    if phone_number.present? && message.present?
      SNS.publish(phone_number: phone_number, message: convert_message_to_sms_format(message))
    end
  end
end
