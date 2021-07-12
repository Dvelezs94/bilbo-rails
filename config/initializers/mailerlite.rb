require 'mailerlite'

MailerLite.configure do |config|
    config.api_key = ENV.fetch('MAILERLITE_API_KEY') {""}
end