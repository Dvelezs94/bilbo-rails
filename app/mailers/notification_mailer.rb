class NotificationMailer < ApplicationMailer
  include MailerHelper

  def new_notification(user:, subject:, message:, link:, link_text:)
    recipient_email = user.email
    recipient_name  = user.name

    subject   = subject
    title     = subject
    greeting  = subject
    link      = link
    link_text = link_text
    message   = message

    generic_mail(subject=subject, title=title, greeting=greeting, message=message, receiver=recipient_email, link=link, link_text=link_text)
  end
end
