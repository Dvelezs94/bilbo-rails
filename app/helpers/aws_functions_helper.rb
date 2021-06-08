require 'aws-sdk-s3'

module AwsFunctionsHelper
  def upload_to_s3(source_path, target_path)
    begin
      bucket_name = ENV.fetch("S3_BUCKET_NAME") {""}
      region = ENV.fetch("S3_AWS_REGION") {""}
      client = Aws::S3::Client.new(region: region)
      response = client.put_object(
        bucket: bucket_name,
        key: target_path,
        body: File.open(source_path),
        expires: Time.now + 900.seconds
      )
      if response.etag
        return "https://#{bucket_name}.s3.amazonaws.com/#{target_path}" #Return the url to download the file (expires in 900 seconds)
      else
        return ""
      end
    rescue => e
      Bugsnag.notify(e)
      return "" # <- empty string so the .present? method returns false
    end
  end
end
