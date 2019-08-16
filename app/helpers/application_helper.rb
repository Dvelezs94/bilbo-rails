module ApplicationHelper

  def user_avatar(user, size=40)
    if user.avatar.attached?
      user.avatar.variant(resize: "#{size}x#{size}!")
    else
      gravatar_image_url(user.email, size: size)
    end
  end
  def notification_helper
  msg = (flash[:alert] || flash[:error] || flash[:notice] || flash[:warning] || flash[:success] || flash[:progress])
  if msg
    case
    when flash[:error] || flash[:alert]
        flash_type = :error
      when flash[:notice]
        flash_type = :notice
      when flash[:warning]
        flash_type = :warning
      when flash[:success]
        flash_type = :success
      when flash[:progress]
        flash_type = :progress
    end
    notification_generator_helper msg, flash_type
  end
end

  def notification_generator_helper msg, flash_type
     js add_gritter(msg, :image => flash_type, :title=>"Bilbo", :sticky => false, :time => 5000 )
  end

  def number_to_currency_credit(number)
    number_to_currency(number, precision: 2, separator: ".", delimiter: ",", format: "%n")
  end

  def number_to_currency_usd(number)
    number_to_currency(number, precision: 2, separator: ".", unit: "$", delimiter: ",", format: "%u %n")
  end
end
