namespace :update_default_images_to_contents do
  desc 'Convert default images to default content'
  task do_it: :environment do
    @ads_downloads = []
    @errors = []
    item = {}
    Board.all.each do |board|
      begin
        start_time = Time.zone.now
        p "Trabajando bilbo: #{board.name}"
        if !board.default_images.nil?
          default_images = board.default_images
        end
        tmp_dir = "tmp/default_images/#{board.slug}"
        Dir.mkdir('tmp/default_images') unless Dir.exist?('tmp/default_images')
        Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)

        default_images.attachments.each.with_index do |attachment, index|
          if attachment.blob.filename.to_s.ends_with?('.jpg') || attachment.blob.filename.to_s.ends_with?('.jpeg')
            original_ad = Tempfile.new([attachment.blob.key.to_s, '.jpeg'], "tmp/default_images/#{board.slug}")
            file_extension = 'jpeg'
            mime_type = 'image/jpeg'
            filename = attachment.blob.filename.to_s
            download_for_campaign(index, board, attachment, original_ad, mime_type, filename)
          elsif attachment.blob.filename.to_s.ends_with?('.png')
            original_ad = Tempfile.new([attachment.blob.key.to_s, '.png'], "tmp/default_images/#{board.slug}")
            file_extension = 'png'
            mime_type = 'image/png'
            filename = attachment.blob.filename.to_s
            download_for_campaign(index, board, attachment, original_ad, mime_type, filename)
          else attachment.blob.filename.to_s.ends_with?('.mp4')
            original_ad = Tempfile.new([attachment.blob.key.to_s, '.mp4'], "tmp/default_images/#{board.slug}")
            file_extension = 'mp4'
            mime_type = 'video/mp4'
            filename = attachment.blob.filename.to_s
            download_for_campaign(index, board, attachment, original_ad, mime_type, filename)

          end
        end
      rescue StandardError => e
        #report
        SlackNotifyWorker.perform_async(e)
        FileUtils.remove_dir('tmp/default_images', true)
        raise e
      end
    end
  end
end

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

def download_for_campaign(index, board, attachment, original_ad, mime_type, filename)
  File.open(original_ad, 'wb') do |f|
    f.write(attachment.download)
  end
  p 'Transformando'
  content = image_data(original_ad, mime_type, filename)
  content_created = board.project.contents.create(multimedia_data: content)
    cont = BoardDefaultContent.new
    cont.board_id = board.id
    cont.content_id = content_created.id
    cont.save
  p 'Finalizado'
end
