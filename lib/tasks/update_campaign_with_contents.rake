namespace :update_campaign_with_contents do
  desc "Convert campaigns to work with contents"
  task :do_it => :environment do
    Content.all.destroy_all
    @ads_downloads = []
    Campaign.where(status: "active").where.not(ad_id: nil).each do |campaign|
      begin
        p "Trabajando campaña: #{campaign.name}"
        ad = Ad.find(campaign.ad_id)
        campaign.update_columns(duration: ad.duration)
        tmp_dir = "tmp/content/#{ad.slug}"
        Dir.mkdir("tmp/content") unless Dir.exist?("tmp/content")
        Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
        if !@ads_downloads.include? ad.id
          @ads_downloads.push(ad.id)
          p "Convirtiendo anuncio: #{ad.name}"
          ad.multimedia.attachments.each.with_index do |attachment, index|
            if attachment.blob.filename.to_s.ends_with?(".jpg") || attachment.blob.filename.to_s.ends_with?(".jpeg")
              original_ad = Tempfile.new(["#{attachment.blob.key}", ".jpeg"], "tmp/content/#{ad.slug}")
              file_extension = "jpeg"
              mime_type = "image/jpeg"
              filename = attachment.blob.filename.to_s
            elsif attachment.blob.filename.to_s.ends_with?(".png")
              original_ad = Tempfile.new(["#{attachment.blob.key}", ".png"], "tmp/content/#{ad.slug}")
              file_extension = "png"
              mime_type = "image/png"
              filename = attachment.blob.filename.to_s
            elsif attachment.blob.filename.to_s.ends_with?(".mp4")
              original_ad = Tempfile.new(["#{attachment.blob.key}", ".mp4"], "tmp/content/#{ad.slug}")
              file_extension = "mp4"
              mime_type = "video/mp4"
              filename = attachment.blob.filename.to_s
            end
            File.open(original_ad, 'wb') do |f|
              f.write(attachment.download)
            end
              p "Transformando"
            content = image_data(original_ad, mime_type, filename)
              p "Creando contenido"
            content_created = campaign.project.contents.create(multimedia_data: content, slug: "#{ad.slug}#{index}")
              p "Contenido creado"
            campaign.board_campaigns.each do |bc|
              p "Creando ContentBoardsCampaigns"
              cont = ContentsBoardCampaign.new
              cont.boards_campaigns_id = bc.id
              cont.content_id = content_created.id
              cont.skip_some_callbacks = true
              cont.save
              p "Creado ContentBoardsCampaigns"
            end
            p "Finalizado"
          end
          FileUtils.remove_dir("tmp/content",true)
      else
          ad.multimedia.attachments.each.with_index do |attachment, index|
            p "Creando contenido: #{ad.slug}#{index}"
           content_repeat = Content.find_by(slug: "#{ad.slug}#{index}")
            campaign.board_campaigns.each do |bc|
              p "Creando ContentBoardsCampaigns"
              cont = ContentsBoardCampaign.new
              cont.boards_campaigns_id = bc.id
              cont.content_id = content_repeat.id
              cont.skip_some_callbacks = true
              cont.save
              p "Creado ContentBoardsCampaigns"
            end
          p "Finalizado"
        end
      end
      rescue => e
        SlackNotifyWorker.perform_async(e)
        puts "Error en proceso de campañas"
        FileUtils.remove_dir("tmp/content",true)
        raise e
      end
    end
    begin
      Ad.where.not(id: @ads_downloads).each do |ad|
        ad.multimedia.attachments.each.with_index do |attachment, index|
          p "Convirtiendo anuncio: #{ad.name}"
          tmp_dir = "tmp/content/#{ad.slug}"
          Dir.mkdir("tmp/content") unless Dir.exist?("tmp/content")
          Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)

          if attachment.blob.filename.to_s.ends_with?(".jpg") || attachment.blob.filename.to_s.ends_with?(".jpeg")
            original_ad = Tempfile.new(["#{attachment.blob.key}", ".jpeg"], "tmp/content/#{ad.slug}")
            file_extension = "jpeg"
            mime_type = "image/jpeg"
            filename = attachment.blob.filename.to_s
          elsif attachment.blob.filename.to_s.ends_with?(".png")
            original_ad = Tempfile.new(["#{attachment.blob.key}", ".png"], "tmp/content/#{ad.slug}")
            file_extension = "png"
            mime_type = "image/png"
            filename = attachment.blob.filename.to_s
          elsif attachment.blob.filename.to_s.ends_with?(".mp4")
            original_ad = Tempfile.new(["#{attachment.blob.key}", ".mp4"], "tmp/content/#{ad.slug}")
            file_extension = "mp4"
            mime_type = "video/mp4"
            filename = attachment.blob.filename.to_s
          end
          File.open(original_ad, 'wb') do |f|
            f.write(attachment.download)
          end
          p "Transformando"
          content = image_data(original_ad, mime_type, filename)
          p "Creando contenido"
          content_created = ad.project.contents.create(multimedia_data: content)
          p "Contenido creado"
        end
        p "Finalizado"
      end
      p "Proceso Finalizado"
    rescue => e
      SlackNotifyWorker.perform_async(e)
      puts "Error en proceso de anuncios"
      FileUtils.remove_dir("tmp/content",true)
      raise e
    end
    p "Borrando carpeta"
    FileUtils.remove_dir("tmp/content",true)
    p "Fin"
  end
end


def image_data(original_ad, mime_type, filename)
  attacher = Shrine::Attacher.new
  attacher.set(uploaded_image(original_ad, mime_type, filename))
  magick = ImageProcessing::MiniMagick.source(original_ad)

  # if you're processing derivatives
  if mime_type == "image/png" || mime_type == "image/jpeg"
    attacher.set_derivatives(
      large:  uploaded_image(magick.resize_to_limit!(1920, 1080), mime_type, filename),
      medium: uploaded_image(magick.resize_to_limit!(960, 540), mime_type, filename),
      small:  uploaded_image(magick.resize_to_limit!(640, 360), mime_type, filename),
    )
  elsif mime_type == "video/mp4"
    video_encoding_settings = {
      #probesize: "100M", analyzeduration: "100M", compression_level: 6, quality: 90, preset: 'default',
      custom: %w(-vf scale=-1:1080)
    }
    transcoded = Tempfile.new ["transcoded", ".mp4"]
    screenshot = Tempfile.new ["screenshot", ".jpg"]

    # transcode video
    movie = FFMPEG::Movie.new(original_ad.path)
    movie.transcode(transcoded.path, video_encoding_settings)

    # get screenshot from transcoded video
    screen = FFMPEG::Movie.new(transcoded.path)
    screen.screenshot(screenshot.path)

    # create image versions
    magick = ImageProcessing::MiniMagick.source(screenshot.path)
      attacher.set_derivatives(
        transcoded: uploaded_image(transcoded, mime_type, filename),
        large:  uploaded_image(magick.resize_to_limit!(1920, 1080), "image/jpeg", filename),
        medium: uploaded_image(magick.resize_to_limit!(960, 540), "image/jpeg", filename),
        small:  uploaded_image(magick.resize_to_limit!(640, 360), "image/jpeg", filename),
      )
  end
  attacher.column_data # or attacher.data in case of postgres jsonb column
end

def uploaded_image(original_ad, mime_type, filename)
  file = File.open(original_ad, binmode: true)
  # for performance we skip metadata extraction and assign test metadata
  uploaded_file = Shrine.upload(file, :store, metadata: true)
  uploaded_file.metadata.merge!(
    "size"      => File.size(file.path),
    "mime_type" => mime_type,
    "filename"  => filename,
  )
  uploaded_file
end
