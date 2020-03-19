class UserMailer  < Devise::Mailer
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  include MailerHelper

  def confirmation_instructions(record, token, opts={})
    @subject   = I18n.t('devise.mailer.confirmation_instructions.subject')
    @title     = I18n.t('devise.mailer.confirmation_instructions.subject')
    @greeting  = I18n.t('devise.mailer.confirmation_instructions.subject')
    @link      = confirmation_url(record, confirmation_token: token)
    @link_text = I18n.t('devise.mailer.confirmation_instructions.link_text')
    @message   = I18n.t('devise.mailer.confirmation_instructions.message', user_name: record.name, link: @link)

    generic_mail(subject=@subject, title=@title, greeting=@greeting, message=@message, receiver=record.email, link=@link, link_text=@link_text)
  end

  def reset_password_instructions(record, token, opts={})
    @token = token
    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": record.email
            }
          ],
          "dynamic_template_data": {
            "ALIAS": record.alias,
            "RESETURL": edit_password_url(record, reset_password_token: @token)
          }
        }
      ],
      "from": {
        "email": "noreply@jalecitos.com",
        "name": "Jalecitos"
      },
      "template_id": "d-038e9bd99cef4c7ebe128b90e6da69cb"
    }

    sendgrid_client.client.mail._("send").post(request_body: (data))
    end
end
