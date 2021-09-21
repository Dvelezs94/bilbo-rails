require "image_processing/mini_magick"
require "streamio-ffmpeg"
require "tempfile"

class ContentUploader < Shrine
  plugin :determine_mime_type, analyzer: :marcel
  plugin :validation_helpers
  plugin :remove_invalid
  metadata_method :width, :height

  IMAGE_TYPES = %w[image/jpeg image/png image/jpg]
  VIDEO_TYPES = %w[video/mp4]

  Attacher.validate do
    validate_extension %w[jpg jpeg png mp4]
    validate_mime_type IMAGE_TYPES + VIDEO_TYPES
    validate_max_size 20 * 1024 * 1024 # 20 MB
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
      frame_rate: 30,
      custom: %w(-vf scale=-2:720 -an)
    }
    transcoded = Tempfile.new ["transcoded", ".mp4"]
    screenshot = Tempfile.new ["screenshot", ".jpg"]

    # transcode video
    movie = FFMPEG::Movie.new(original.path)
    if movie.height.to_i > 720
      movie.transcode(transcoded.path, video_encoding_settings )
    else
      movie.transcode(transcoded.path)
    end

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
end
