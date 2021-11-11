namespace :update_board_images_to_shrine do
  desc 'Convert board images to use shrine'
  task do_it: :environment do
    include ShrineContentHelper
    @ads_downloads = []
    @errors = []
    item = {}
    Board.all.each do |board|
      begin
        start_time = Time.zone.now
        p "Trabajando bilbo: #{board.name}"
        if !board.images.nil?
          images = board.images
        end
        tmp_dir = "tmp/images/#{board.slug}"
        Dir.mkdir('tmp/images') unless Dir.exist?('tmp/images')
        Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
        images.attachments.each.with_index do |attachment, index|
          existing_photo = MapPhoto.find_by_slug(attachment.filename.to_s + board.project.slug)
          if existing_photo.present?
            if !BoardMapPhoto.find_by(board_id: board.id, map_photo_id: existing_photo.id).present?
              photo = BoardMapPhoto.new
              photo.board_id = board.id
              photo.map_photo_id = existing_photo.id
              photo.save
            end
          else
            if attachment.content_type.in? ["image/jpeg", "image/jpg"]
              original_ad = Tempfile.new([attachment.blob.key.to_s, '.jpeg'], "tmp/images/#{board.slug}")
              file_extension = 'jpeg'
              mime_type = 'image/jpeg'
              filename = attachment.blob.filename.to_s
              attach_board_photo(index, board, attachment, original_ad, mime_type, filename)
            elsif attachment.content_type == "image/png"
              original_ad = Tempfile.new([attachment.blob.key.to_s, '.png'], "tmp/images/#{board.slug}")
              file_extension = 'png'
              mime_type = 'image/png'
              filename = attachment.blob.filename.to_s
              attach_board_photo(index, board, attachment, original_ad, mime_type, filename)
            end
          end
        end
      rescue StandardError => e
        SlackNotifyWorker.perform_async(e)
        FileUtils.remove_dir('tmp/images', true)
        raise e
      end
    end
  end
end

def attach_board_photo(index, board, attachment, original_ad, mime_type, filename)
  File.open(original_ad, 'wb') do |f|
    f.write(attachment.download)
  end
  p 'Transformando'
  photo = image_data(original_ad, mime_type, filename)
  photo_created = MapPhoto.create(image_data: photo, slug: filename+board.project.slug)
  board_photo = BoardMapPhoto.new
  board_photo.board_id = board.id
  board_photo.map_photo_id = photo_created.id
  board_photo.save
  p 'Finalizado'
end
