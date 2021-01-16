# using SendGrid's Ruby Library
# https://github.com/sendgrid/sendgrid-ruby
module SendgridHelper
  def SplitNames( name )
    # Separate the full name into spaces.
    tokens = name.split(" ")
    # List where the words of the name are saved.
    names = []
    # Words of surnames and compound names.
    especial_tokens = ['de','del', 'la', 'las', 'los']

    prev = ""
    for token in tokens do
      _token = token.downcase
      if especial_tokens.include? _token
        prev += token + " "
      else
        names.append(prev + token)
        prev = ""
      end
      num_names_final = names.length
      names_final, last_name, second_surname = "", "", ""

      # When there is no name.
      if num_names_final == 0
          names_final = ""

      # When the name consists of a single element.
      elsif num_names_final == 1
        names_final = names[0]

      # When the name consists of two elements.
      elsif num_names_final == 2
        names_final = names[0]
        last_name = names[1]

      # When the name consists of three elements.
      elsif num_names_final == 3
        names_final = names[0]
        last_name = names[1]
        second_surname = names[2]

      # When the name consists of more than three elements.
      else
        names_final = names[0] + " " + names[1]
        last_name = names[2]
        second_surname = names[3]
      end

      names_final = names_final
      last_name = last_name
      second_surname = second_surname

    p array_names =  [names_final.split.map(&:capitalize).join(' '), last_name.split.map(&:capitalize).join(' '), second_surname.split.map(&:capitalize).join(' ')]

    end
    return array_names
  end





  def parseName(input)
    fullName = input rescue " "
    result = {}
    if (fullName.length > 0)
     nameTokens = Hash[fullName.split(" ")]
     #fullName.match("[A-ZÁ-ÚÑÜ][a-zá-úñü]+|([aeodlsz]+\s+)+") || []

     if (nameTokens.length > 3)
      result = nameTokens.slice(0, 2).join(' ')
      else
      result = nameTokens.slice(0, 1).join(' ')
     end

     if (nameTokens.length > 2)
      result.lastName = nameTokens.slice(-2, -1).join(' ')
      result.secondLastName = nameTokens.slice(-1).join(' ')
      else
      result.lastName = nameTokens.slice(-1).join(' ')
      result.secondLastName = ""
     end
    end

    return result

  end

  def sync_sendgrid_user(user)
    if Rails.env.production?
      require 'uri'
      require 'net/http'
      array = SplitNames(user.name)
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
      request.body = "{\"list_ids\":[\"#{list_id}\"],\"contacts\":[{\"address_line_1\":\"string (optional)\",\"address_line_2\":\"string (optional)\",\"alternate_emails\":[\"#{user.email}\"],\"city\":\"string (optional)\",\"country\":\"string (optional)\",\"email\":\"#{user.email}\",\"first_name\":\"#{array[0]}\",\"last_name\":\"#{array[1] + " " + array[2] }\",\"postal_code\":\"string (optional)\",\"state_province_region\":\"string (optional)\",\"custom_fields\":{}}]}"
      response = http.request(request)
    end
  end
end
