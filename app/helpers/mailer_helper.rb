module MailerHelper
  def sendgrid_client
    require 'sendgrid-ruby'
    @sendgrid_client = SendGrid::API.new(api_key: ENV.fetch('SENDGRID_API_KEY'))
  end

  def merge_to_hash(hash, key, content)
    hash[key] = {
      content: content,
      # needed for conditions on sendgrid
      # https://sendgrid.com/docs/for-developers/sending-email/using-handlebars/#conditional-statements
      enabled: true
    }
  end

  def generic_mail(subject, title, greeting, message, receiver, link=nil, link_text=nil, image_url=nil, preheader=nil)
    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": receiver
            }
          ],
          "dynamic_template_data": {
            "subject": subject,
            "title": title,
            "greeting": greeting,
            "message": message,
            "preheader": preheader
          }
        }
      ],
      "from": {
        "email": "noreply@mybilbo.mx",
        "name": "Bilbo"
      },
      "template_id": "d-d810424f384a47c1a187f980299f18d4"
    }
    dynamic_template_data_hash = data[:personalizations][0][:dynamic_template_data]
    merge_to_hash(dynamic_template_data_hash, :link, link) if link.present?
    merge_to_hash(dynamic_template_data_hash, :link_text, link_text) if link_text.present?
    merge_to_hash(dynamic_template_data_hash, :image_url, image_url) if image_url.present?

    puts "x" * 500
    puts data

    sendgrid_client.client.mail._("send").post(request_body: (data))
  end
end
