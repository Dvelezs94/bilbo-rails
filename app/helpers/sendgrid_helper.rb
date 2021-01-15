# using SendGrid's Ruby Library
# https://github.com/sendgrid/sendgrid-ruby
module SendgridHelper

  def sync_sendgrid_user(user)
    p "x" * 800
    names = user.name.split(" ")
    if names.length == 1
      @name = names[0].to_s
      @last_name = "string (optional)"
    elsif names.length == 2
      @name = names[0]
      @last_name = names[1]
    elsif names.length == 3
      @name = names[0]
      @last_name = names[1] + " " + names[2]
    elsif names.length == 4
      @name = names[0] + " " + names[1]
      @last_name = names[2] + " " + names[3]
    else
      i = 0
      p ";;"
      while i < names.length
        p names.include? "De"


        if names.include? "De"
          o = 0
          while o < names.find_index("De")
            @aux = names[i] + " "
            @names += @aux
            o += 1
          end
          while o >= names.find_index("De")
            @last_name += names[i] + " "
          end
        end
        i += 1
      end
    end
    p @name
    p @last_name

    if Rails.env.production?
      require 'uri'
      require 'net/http'
      url = URI("https://api.sendgrid.com/v3/marketing/contacts")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      if user.is_provider?
        list_id = "1e4063ab-c4d3-4e83-8987-3a388e9dbcb3"
      else
        list_id = "4e7b5aeb-302c-465e-b667-13dbae1d7bd7"
      end

      request = Net::HTTP::Put.new(url)
      request["authorization"] = "#{SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"]).request_headers.first[1]}"
      request["content-type"] = 'application/json'
      request.body = "{\"list_ids\":[\"#{list_id}\"],\"contacts\":[{\"address_line_1\":\"string (optional)\",\"address_line_2\":\"string (optional)\",\"alternate_emails\":[\"#{user.email}\"],\"city\":\"string (optional)\",\"country\":\"string (optional)\",\"email\":\"#{user.email}\",\"first_name\":\"#{user.name}\",\"last_name\":\"string (optional)\",\"postal_code\":\"string (optional)\",\"state_province_region\":\"string (optional)\",\"custom_fields\":{}}]}"
      response = http.request(request)
      #puts response.read_body
    end
  end
end
