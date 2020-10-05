class ImageResizeWorker
  include Sidekiq::Worker
  include ApplicationHelper
  sidekiq_options retry: 3, dead: false

  def perform(ad_id)
    ad = Ad.find(ad_id)

    ad.images.each do |img|
      meta = get_image_size_from_metadata(img)
      if meta[:height]>1080 && !img.processed
        begin
          retries ||= 0
          puts "attempt to convert image number ##{ retries }"
          if img.blob.filename.to_s.ends_with?(".jpg") || img.blob.filename.to_s.ends_with?(".jpeg")
            orig_img_tmpfile = Tempfile.new(["#{img.blob.key}", ".jpeg"], "tmp/multimedia")
            file_extension = "jpeg"
          elsif img.blob.filename.to_s.ends_with?(".png")
            orig_img_tmpfile = Tempfile.new(["#{img.blob.key}", ".png"])
            file_extension = "png"
          end
          File.open(orig_img_tmpfile, 'wb') do |f|
            f.write(img.download)
          end

          image = MiniMagick::Image.open(orig_img_tmpfile.path)
          image.resize "x1080"
          image.write(orig_img_tmpfile.path)

          new_attachment = ad.multimedia.attach(io: File.open(orig_img_tmpfile), filename: "#{img.blob.filename.base}."+file_extension, content_type: 'image/'+file_extension)
          ad.multimedia.last.update(processed: true)
          delete_img(orig_img_tmpfile, img)
        rescue
          delete_img(orig_img_tmpfile, img)
          retry if (retries += 1) < 4
          delete_img(orig_img_tmpfile, img)
          puts "Conversion image failed"
        end
      else
        img.update(processed: true)
      end
    end
  end

  def delete_img(orig_img_tmpfile, mm)
    if orig_img_tmpfile.present?
      orig_img_tmpfile.close
      orig_img_tmpfile.unlink
    end
    if mm.present?
      mm.destroy!
    end
  end

end
