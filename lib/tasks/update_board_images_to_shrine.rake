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
          if attachment.blob.filename.to_s.ends_with?('.jpg') || attachment.blob.filename.to_s.ends_with?('.jpeg')
            original_ad = Tempfile.new([attachment.blob.key.to_s, '.jpeg'], "tmp/images/#{board.slug}")
            file_extension = 'jpeg'
            mime_type = 'image/jpeg'
            filename = attachment.blob.filename.to_s
            download_for_board(index, board, attachment, original_ad, mime_type, filename)
          elsif attachment.blob.filename.to_s.ends_with?('.png')
            original_ad = Tempfile.new([attachment.blob.key.to_s, '.png'], "tmp/images/#{board.slug}")
            file_extension = 'png'
            mime_type = 'image/png'
            filename = attachment.blob.filename.to_s
            download_for_board(index, board, attachment, original_ad, mime_type, filename)
        end
      rescue StandardError => e
        SlackNotifyWorker.perform_async(e)
        FileUtils.remove_dir('tmp/images', true)
        raise e
      end
    end
  end
end

def download_for_board(index, board, attachment, original_ad, mime_type, filename)
  File.open(original_ad, 'wb') do |f|
    f.write(attachment.download)
  end
  p 'Transformando'
  photo = image_data(original_ad, mime_type, filename)
  photo_created = board.board_photos.create(image_data: content)
  p 'Finalizado'
end
