module ApplicationHelper

  def user_avatar(user, size=40)
    if user.avatar.attached?
      user.avatar.variant(resize: "#{size}x#{size}!")
    else
      gravatar_image_url(user.email, size: size)
    end
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
    if image.metadata[:height].present?
      image.metadata
    else
      ActiveStorage::Analyzer::ImageAnalyzer.new(image).metadata
    end
  end

  def send_sms(phone_number, message)
    if phone_number.present? && message.present?
      SNS.publish(phone_number: phone_number, message: message)
    end
  end
end
