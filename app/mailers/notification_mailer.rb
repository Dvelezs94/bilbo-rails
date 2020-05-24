class NotificationMailer < ApplicationMailer
  include MailerHelper

  def new_notification(notification)
    @recipient_email = notification.recipient.email
    @recipient_name  = notification.recipient.name
    @action          = notification.build_action_message
    @subject   = I18n.t('devise.mailer.confirmation_instructions.subject')
    @title     = I18n.t('devise.mailer.confirmation_instructions.subject')
    @greeting  = I18n.t('devise.mailer.confirmation_instructions.subject')
    @link      = confirmation_url(record, confirmation_token: token)
    @link_text = I18n.t('devise.mailer.confirmation_instructions.link_text')
    @message   = I18n.t('devise.mailer.confirmation_instructions.message', user_name: record.name, link: @link)

    generic_mail(subject=subject, title=title, greeting=greeting, message=message, receiver=recipient_email, link=link, link_text=link_text)
  end
end
