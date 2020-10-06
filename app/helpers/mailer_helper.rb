module MailerHelper
  def sendgrid_client
    require 'sendgrid-ruby'
    @sendgrid_client = SendGrid::API.new(api_key: ENV.fetch('SENDGRID_API_KEY'))
  end

  def generic_mail(subject, greeting, message, receiver, link=nil, link_text=nil, image_url=nil, preheader=nil)
    @link = link || "https://app.bilbo.mx/"
    @link_text = link_text || "Ir a Bilbo"
    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": receiver
            }
          ],
          "dynamic_template_data": {
            "SUBJECT": subject,
            "GREETING": greeting,
            "MESSAGE": message,
            "LINK": @link,
            "LINK_TEXT": @link_text
          }
        }
      ],
      "from": {
        "email": "noreply@bilbo.mx",
        "name": "Bilbo"
      },
      "template_id": "d-16b54061474043a18eea73ea4fa3750a"
    }
    sendgrid_client.client.mail._("send").post(request_body: (data))
  end
end
