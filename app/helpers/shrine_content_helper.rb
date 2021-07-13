module ShrineContentHelper
  # Workers and rake tasks
  def image_data(original_ad, mime_type, filename)
    attacher = Shrine::Attacher.new
    attacher.set(uploaded_image(original_ad, filename))
    magick = ImageProcessing::MiniMagick.source(original_ad)

    # if you're processing derivatives
    if ['image/png', 'image/jpeg'].include?(mime_type)
      attacher.set_derivatives(
        large: uploaded_image(magick.resize_to_limit!(1920, 1080), filename),
        medium: uploaded_image(magick.resize_to_limit!(960, 540), filename),
        small: uploaded_image(magick.resize_to_limit!(640, 360), filename)
      )
    elsif mime_type == 'video/mp4'
      video_encoding_settings = {
        frame_rate: 30,
        custom: %w(-vf scale=-2:720 -an)
      }
      transcoded = Tempfile.new ['transcoded', '.mp4']
      screenshot = Tempfile.new ['screenshot', '.jpg']

      # transcode video
      movie = FFMPEG::Movie.new(original_ad.path)
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
      attacher.set_derivatives(
        transcoded: uploaded_image(transcoded, filename),
        large: uploaded_image(magick.resize_to_limit!(1920, 1080), filename),
        medium: uploaded_image(magick.resize_to_limit!(960, 540), filename),
        small: uploaded_image(magick.resize_to_limit!(640, 360), filename)
      )
    end
    attacher.column_data # or attacher.data in case of postgres jsonb column
  end

  def uploaded_image(original_ad, filename)
    file = File.open(original_ad, binmode: true)
    # for performance we skip metadata extraction and assign test metadata
    uploaded_file = Shrine.upload(file, :store, metadata: true)
    uploaded_file.metadata.merge!(
      'size' => File.size(file.path),
      'filename' => filename
    )
    uploaded_file
  end
end
