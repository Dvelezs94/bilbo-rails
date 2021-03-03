<<<<<<< HEAD
require "image_processing/mini_magick"
require "streamio-ffmpeg"
require "tempfile"

class ContentUploader < Shrine
  metadata_method :width, :height
  IMAGE_TYPES = %w[image/jpeg image/png image/jpg]
  VIDEO_TYPES = %w[video/mp4]

  Attacher.validate do
    validate_mime_type IMAGE_TYPES + VIDEO_TYPES
  end

  Attacher.derivatives do |original|
    case file.mime_type
      when *IMAGE_TYPES then process_derivatives(:image, original)
      when *VIDEO_TYPES then process_derivatives(:video, original)
    end
  end

  Attacher.derivatives :image do |original|
    magick = ImageProcessing::MiniMagick.source(original)

    {
      small:  magick.resize_to_limit!(640, 360),
      medium: magick.resize_to_limit!(960, 540),
      large: magick.resize_to_limit!(1920, 1080)
    }
  end

  Attacher.derivatives :video do |original|
    video_encoding_settings = {
      #probesize: "100M", analyzeduration: "100M", compression_level: 6, quality: 90, preset: 'default',
      custom: %w(-vf scale=-1:1080)
    }
    transcoded = Tempfile.new ["transcoded", ".mp4"]
    screenshot = Tempfile.new ["screenshot", ".jpg"]

    # transcode video
    movie = FFMPEG::Movie.new(original.path)
    movie.transcode(transcoded.path, video_encoding_settings)

    # get screenshot from transcoded video
    screen = FFMPEG::Movie.new(transcoded.path)
    screen.screenshot(screenshot.path)

    # create image versions
    magick = ImageProcessing::MiniMagick.source(screenshot.path)

    {
      transcoded: transcoded,
      small:  magick.resize_to_limit!(640, 360),
      medium: magick.resize_to_limit!(960, 540),
      large: magick.resize_to_limit!(1920, 1080)
    }
  end
=======
class ContentUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  if Rails.env.test? || Rails.env.development?
    storage :file
  else
    storage :fog
  end
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  #single image size
  def size_range
    1..10.megabytes
  end

  def filename
    "#{original_filename}" if original_filename
  end

  # Permissions for file upload
  def aws_acl
    "public-read"
  end


  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fit: [100, 100]
  end

  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_allowlist
    %w(jpg jpeg png mp4)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
>>>>>>> ad redesign first commit
end
