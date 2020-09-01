class ImageResizeWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false
  #require 'mini_magick'

  def perform(ad_id,mm_id)
    ad = Ad.find(ad_id)
    mm = ad.multimedia.find(mm_id)
    orig_img_tmpfile = Tempfile.new(["#{mm.blob.key}", ".jpeg"])

    File.open(orig_img_tmpfile, 'wb') do |f|
      f.write(mm.download)
    end

    image = MiniMagick::Image.open(orig_img_tmpfile.path)
    if image.dimensions[1]>1080
      image.resize "x1080"
    end

    image.write(orig_img_tmpfile.path)
    ad.multimedia.attach(io: File.open(orig_img_tmpfile), filename: "#{mm.blob.filename.base}.jpg", content_type: 'image/jpg')
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
