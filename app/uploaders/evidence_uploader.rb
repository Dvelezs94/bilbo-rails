require "tempfile"

class EvidenceUploader < Shrine
  def upload(io, **options)
    fail FileTooLarge if io.size >= 10*1024*1024
    super
  end

  metadata_method :width, :height
  IMAGE_TYPES = %w[image/jpeg image/png image/jpg]
  VIDEO_TYPES = %w[video/mp4]

  Attacher.validate do
    validate_mime_type IMAGE_TYPES + VIDEO_TYPES
  end
end
