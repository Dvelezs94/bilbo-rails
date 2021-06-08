require 'fog-aws'

if Rails.env.development?
  Fog.credentials = {
    region: ENV.fetch('S3_AWS_REGION') {""},
    aws_access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID") {""},
    aws_secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY") {""}
  }
else
  Fog.credentials = {
    region: ENV.fetch('S3_AWS_REGION') {""},
    use_iam_role: true
  }
end
