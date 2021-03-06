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
    if Rails.env.production? || Rails.env.staging? || Rails.env.demo?
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

  # remove non valid characters for SMS like ??, ??, etc... and replace with similar
  # versions like ?? => n, ?? => a, etc..
  def convert_message_to_sms_format(msg)
    return I18n.transliterate("[Bilbo]#{msg}")
  end

  def send_sms(phone_number, message)
    if phone_number.present? && message.present?
      begin
        sms_messages = ClickSendClient::SmsMessageCollection.new

        sms_messages.messages = [
          ClickSendClient::SmsMessage.new(
            "to": phone_number,
            "source": "rails",
            "body": convert_message_to_sms_format(message)
          )
        ]

        CLICKSEND_SMS.sms_send_post(sms_messages)
      rescue ClickSendClient::ApiError => e
        raise "Exception when calling Clicksend SMSApi->sms_send_post: #{e.response_body}"
      rescue => e
        SlackNotifyWorker.perform_async("Error sending message to: #{phone_number}. Message: #{convert_message_to_sms_format(message)}", senderid: "Bilbo")
      end
    end
  end

  def time_diff(start_time, end_time)
    seconds_diff = (start_time - end_time).to_i.abs

    hours = seconds_diff / 3600
    seconds_diff -= hours * 3600

    minutes = seconds_diff / 60
    seconds_diff -= minutes * 60

    seconds = seconds_diff

    "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
  end

  def relative_time(start_time)
    # returns readable time format
    # 50 seconds ago
    # 45 minute ago
    # 8 hours ago...
    diff_seconds = (Time.now - start_time).to_i
    case diff_seconds
      when 0 .. 59
        return I18n.t("time_day.formatted.seconds_ago", input_time: diff_seconds) 
      when 60 .. (3600-1)
        return I18n.t("time_day.formatted.minutes_ago", input_time: diff_seconds/60)
      when 3600 .. (3600*24-1)
        return I18n.t("time_day.formatted.hours_ago", input_time: diff_seconds/3600) 
      when (3600*24) .. (3600*24*30) 
        return I18n.t("time_day.formatted.days_ago", input_time: diff_seconds/(3600*24))
      else
        return start_time.strftime("%m/%d/%Y")
    end
  end
  

  def generate_thumbnail(media, height, width)
    if media.video?
      if media.previewable?
         return url_from_media_preview(media.preview(resize_to_limit: [height, width]).processed)
      else
        return url_from_media(media)
      end
    else
      if media.variable?
        return url_from_media_preview(media.variant(resize_to_limit: [height, width]).processed)
      else
        return url_from_media(media)
      end
    end
  end

  def url_from_media_preview(media)
    if Rails.env.production? || Rails.env.staging? || Rails.env.demo?
      "https://#{ENV.fetch('CDN_HOST')}#{URI.parse(media.service_url).path}"
    else
      url_for(media.image)
    end
  end

end
