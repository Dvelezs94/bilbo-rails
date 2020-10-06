class NotificationMailer < ApplicationMailer
  include MailerHelper

  def new_notification(user:, subject:, message:, link: nil, link_text: nil)
    recipient_email = user.email
    recipient_name  = user.name_or_email

    subject   = subject
    title     = subject
    greeting  = t('mailer.hi', name: recipient_name)
    link      = link
    link_text = link_text
    message   = message
    generic_mail(subject=subject, title=title, greeting=greeting, message=message, receiver=recipient_email, link=link, link_text=link_text)
  end
end
