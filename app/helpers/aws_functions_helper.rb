module AwsFunctionsHelper
  def upload_to_s3(source_path, target_path)
    begin
      s3 = Fog::Storage.new(provider: 'AWS')
      bucket_name = ENV.fetch("S3_BUCKET_NAME")
      bucket = s3.directories.get(bucket_name)
      file = bucket.files.create(key: target_path, body: File.open(source_path))
      return file.url(Time.now + 900) #Return the url to download the file (expires in 900 seconds)
    rescue => e
      Bugsnag.notify(e)
      return "" # <- empty string so the .present? method returns false
    end
  end
end
