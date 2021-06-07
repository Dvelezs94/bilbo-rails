module AwsFunctionsHelper
  def upload_to_s3(source_path, target_path)
    begin
      s3 = Aws::S3::Resource.new()
      bucket_name = ENV.fetch("S3_BUCKET_NAME")
      bucket = s3.bucket(bucket_name)
      object = bucket.object(target_path)
      File.open(source_path, 'rb') do |file|
        object.put(body: file)
      end
      return object.presigned_url(:get) #Return the url to download the file
    rescue => e
      Bugsnag.notify(e)
      return "" # <- empty string so the .present? method returns false
    end
  end
end
