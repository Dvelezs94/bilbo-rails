class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@bilbo.mx'
  include MailerHelper
end
