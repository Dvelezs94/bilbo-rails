class UserMailer  < Devise::Mailer
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  include MailerHelper

  def confirmation_instructions(record, token, opts={})
    @subject   = I18n.t('devise.mailer.confirmation_instructions.subject')
    @greeting  = t('mailer.hi', name: record.name_or_none)
    @link      = confirmation_url(record, confirmation_token: token)
    @link_text = I18n.t('devise.mailer.confirmation_instructions.link_text')
    @message   = I18n.t('devise.mailer.confirmation_instructions.message', user_name: record.name, link: @link)

    generic_mail(subject=@subject, greeting=@greeting, message=@message, receiver=record.email, link=@link, link_text=@link_text)
  end

  def reset_password_instructions(record, token, opts={})
    @subject   = I18n.t('devise.mailer.reset_password_instructions.subject')
    @greeting  = t('mailer.hi', name: record.name_or_none)
    @link      = edit_password_url(record, reset_password_token: token)
    @link_text = I18n.t('devise.mailer.reset_password_instructions.link_text')
    @message   = I18n.t('devise.mailer.reset_password_instructions.message', user_name: record.name, link: @link)

    generic_mail(subject=@subject, greeting=@greeting, message=@message, receiver=record.email, link=@link, link_text=@link_text)
  end

  def invitation_instructions(record, token, opts={})
    @subject   = I18n.t('devise.mailer.invitation_instructions.subject')
    @greeting  = t('mailer.hi', name: record.name_or_none)
    @link      = accept_user_invitation_url(invitation_token: token)
    @link_text = I18n.t('devise.mailer.invitation_instructions.link_text')
    @message   = I18n.t('devise.mailer.invitation_instructions.message', user_name: record.name, link: @link)

    generic_mail(subject=@subject, greeting=@greeting, message=@message, receiver=record.email, link=@link, link_text=@link_text)
  end

  def monthly_provider_report(user, month, net_earnings, campaign_count, percentage_comparison, link)
    data = {
      "personalizations": [
        {
          "to": [
            {
              "email": user.email
            }
          ],
          "dynamic_template_data": {
            "NAME": user.name_or_none,
            "MONTH": month,
            "NET_EARNINGS": net_earnings,
            "CAMPAIGN_COUNT": campaign_count,
            "PERCENTAGE": percentage_comparison,
            "LINK": link
          }
        }
      ],
      "from": {
        "email": "contabilidad@bilbo.mx",
        "name": "Bilbo"
      },
      "template_id": "d-f3f33770a1594fd39cbc1e7a5c4051af"
    }
    sendgrid_client.client.mail._("send").post(request_body: (data))
  end
end
