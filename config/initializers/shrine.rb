require "shrine"
require "shrine/storage/file_system"
require "shrine/storage/s3"

if Rails.env.production? || Rails.env.demo? || Rails.env.staging?
  s3_options = {
    bucket: ENV.fetch('S3_BUCKET_NAME') {""},
    region: ENV.fetch('S3_AWS_REGION') {'us-east-1'},
  }

  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "cache", **s3_options),
    store: Shrine::Storage::S3.new(**s3_options),
  }

  Shrine.plugin :url_options, store: { host: "https://#{ENV.fetch('CDN_HOST') {""}}/" }

else
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads"),       # permanent
  }
end

Shrine.plugin :activerecord           # loads Active Record integration
Shrine.plugin :cached_attachment_data # enables retaining cached file across form redisplays
Shrine.plugin :restore_cached_data    # extracts metadata for assigned cached files
Shrine.plugin :validation
Shrine.plugin :validation_helpers
Shrine.plugin :store_dimensions, analyzer: :mini_magick
Shrine.plugin :derivatives
Shrine.plugin :add_metadata
Shrine.plugin :determine_mime_type
