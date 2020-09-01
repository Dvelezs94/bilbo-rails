class ImageResizeWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false
  #require 'mini_magick'

  def perform(ad_id,mm_id)
    ad = Ad.find(ad_id)
    mm = ad.multimedia.find(mm_id)

    if mm.blob.filename.to_s.ends_with?(".jpg") || mm.blob.filename.to_s.ends_with?(".jpeg")
      orig_img_tmpfile = Tempfile.new(["#{mm.blob.key}", ".jpeg"])
      file_extension = "jpeg"
    elsif mm.blob.filename.to_s.ends_with?(".png")
      orig_img_tmpfile = Tempfile.new(["#{mm.blob.key}", ".png"])
      file_extension = "png"
    end
    p "AAAAAAAAAAAAA"*100
    File.open(orig_img_tmpfile, 'wb') do |f|
      f.write(mm.download)
    end
    image = MiniMagick::Image.open(orig_img_tmpfile.path)
    p image.dimensions
    if image.dimensions[1]>1080
      p image.dimensions
      image.resize "x1080"
    end
    p image.dimensions

    image.write(orig_img_tmpfile.path)
    ad.multimedia.attach(io: File.open(orig_img_tmpfile), filename: "#{mm.blob.filename.base}."+file_extension, content_type: 'image/'+file_extension)
    delete_img(orig_img_tmpfile,mm)
  end
  def delete_img(orig_img_tmpfile,mm)
    orig_img_tmpfile.close
    orig_img_tmpfile.unlink
    if mm.present?
      mm.destroy!
    end
  end
end
