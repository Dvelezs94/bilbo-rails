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
      frame_rate: 30,
      custom: %w(-vf scale=-2:720 -an)
      #custom: %w(-vf scale=trunc(iw/2)*2:720 -an)
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
