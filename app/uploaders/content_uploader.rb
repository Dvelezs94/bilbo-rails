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

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
