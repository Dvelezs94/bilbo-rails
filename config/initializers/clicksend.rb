require 'clicksend_client'

# Setup authorization
ClickSendClient.configure do |config|
  # Configure HTTP basic authorization: BasicAuth
  config.username = ENV.fetch('CLICKSEND_USERNAME') {""}
  config.password = ENV.fetch('CLICKSEND_PASSWORD') {""}
end

api_instance = ClickSendClient::AccountApi.new

begin
  # Test Get account information
  api_instance.account_get
  CLICKSEND_SMS = ClickSendClient::SMSApi.new
rescue ClickSendClient::ApiError => e
  Bugsnag.notify("Exception when calling Clicksend API AccountApi->account_get: #{e}")
end