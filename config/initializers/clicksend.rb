require 'clicksend'

# put your own credentials here
username = ENV.fetch('CLICKSEND_USERNAME') {""}     # Your ClickSend username.
api_key = ENV.fetch('CLICKSEND_API_KEY') {""}   # Your Secure Unique API key.

# set up a client to talk to the ClickSend REST API
CLICKSEND_CLIENT = ClickSend::REST::Client.new(:username => username, :api_key => api_key)
