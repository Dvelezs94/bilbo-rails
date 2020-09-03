# Initializes the SNS client for sending SMS messages
SNS = Aws::SNS::Client.new(region: "us-east-1")
