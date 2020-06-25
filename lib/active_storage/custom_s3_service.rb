require "active_storage/service/s3_service"
require 'uri'

class ActiveStorage::Service::CustomS3Service < ActiveStorage::Service::S3Service
  private

    def public_url(key, **)
      url = object_for(key).public_url
      "https://#{ ENV['CDN_HOST'] }/#{URI(url).path}"
    end
end