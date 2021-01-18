# using SendGrid's Ruby Library
# https://github.com/sendgrid/sendgrid-ruby
module SendgridHelper
  def sync_sendgrid_user(user)
    if Rails.env.production?
      require 'uri'
      require 'net/http'
      url = URI("https://api.sendgrid.com/v3/marketing/contacts")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      array = SplitNames(user.name)
      if user.is_provider?
        list_id = "1e4063ab-c4d3-4e83-8987-3a388e9dbcb3"
      elsif user.is_user?
        list_id = "4e7b5aeb-302c-465e-b667-13dbae1d7bd7"
      end
      request = Net::HTTP::Put.new(url)
      request["authorization"] = "#{SendGrid::API.new(api_key: ENV["SENDGRID_API_KEY"]).request_headers.first[1]}"
      request["content-type"] = 'application/json'
      request.body = "{\"list_ids\":[\"#{list_id}\"],\"contacts\":[{\"address_line_1\":\"string (optional)\",\"address_line_2\":\"string (optional)\",\"alternate_emails\":[\"#{user.email}\"],\"city\":\"string (optional)\",\"country\":\"string (optional)\",\"email\":\"#{user.email}\",\"first_name\":\"#{array[0]}\",\"last_name\":\"#{array[1]}\",\"postal_code\":\"string (optional)\",\"state_province_region\":\"string (optional)\",\"custom_fields\":{}}]}"
      response = http.request(request)
    end
  end

  def SplitNames( name )
    name = name.split(" ")
    @name = ""
    @last_name = ""
     i = 0
     while i < name.length
       if i == 0
         @name = name[i]
       else
         @last_name += name[i] + " "
       end
       i+=1
     end
   array_names = [@name, @last_name]
   return array_names
  end
end
