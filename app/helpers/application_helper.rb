module ApplicationHelper

  def user_avatar(user, size=40)
    if user.avatar.attached?
      user.avatar.variant(resize: "#{size}x#{size}!")
    else
      gravatar_image_url(user.email, size: size)
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
end
