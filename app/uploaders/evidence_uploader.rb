require "image_processing/mini_magick"
require "streamio-ffmpeg"
require "tempfile"

class EvidenceUploader < Shrine
  metadata_method :width, :height
  IMAGE_TYPES = %w[image/jpeg image/png image/jpg]
  VIDEO_TYPES = %w[video/mp4]

  Attacher.validate do
    validate_mime_type IMAGE_TYPES + VIDEO_TYPES
  end
end
