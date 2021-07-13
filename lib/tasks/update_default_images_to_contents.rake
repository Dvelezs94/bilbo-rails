namespace :update_default_images_to_contents do
  desc 'Convert default images to default content'
  task do_it: :environment do
    include ShrineContentHelper
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
            download_for_board(index, board, attachment, original_ad, mime_type, filename)
          elsif attachment.blob.filename.to_s.ends_with?('.png')
            original_ad = Tempfile.new([attachment.blob.key.to_s, '.png'], "tmp/default_images/#{board.slug}")
            file_extension = 'png'
            mime_type = 'image/png'
            filename = attachment.blob.filename.to_s
            download_for_board(index, board, attachment, original_ad, mime_type, filename)
          else attachment.blob.filename.to_s.ends_with?('.mp4')
            original_ad = Tempfile.new([attachment.blob.key.to_s, '.mp4'], "tmp/default_images/#{board.slug}")
            file_extension = 'mp4'
            mime_type = 'video/mp4'
            filename = attachment.blob.filename.to_s
            download_for_board(index, board, attachment, original_ad, mime_type, filename)

          end
        end
      rescue StandardError => e
        SlackNotifyWorker.perform_async(e)
        FileUtils.remove_dir('tmp/default_images', true)
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
  content = image_data(original_ad, mime_type, filename)
  content_created = board.project.contents.create(multimedia_data: content)
    cont = BoardDefaultContent.new
    cont.board_id = board.id
    cont.content_id = content_created.id
    cont.save
  p 'Finalizado'
end
