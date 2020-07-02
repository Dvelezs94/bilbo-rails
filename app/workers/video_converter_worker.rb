class VideoConverterWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false
  require 'streamio-ffmpeg'
  def perform(ad_id, mm_id)
    ad = Ad.find(ad_id)
    mm = ad.multimedia.find(mm_id)
    orig_video_tmpfile = Tempfile.new(["#{mm.blob.key}", ".mp4"])
    webp_video_tmpfile = Tempfile.new(["#{mm.blob.key}", ".webp"])

    File.open(orig_video_tmpfile, 'wb') do |f|
      f.write(mm.download)
    end

      movie = FFMPEG::Movie.new(orig_video_tmpfile.path)
      movie.transcode(webp_video_tmpfile.path, video_encoding_settings)
      ad.multimedia.attach(io: File.open(webp_video_tmpfile), filename: "#{mm.blob.filename.base}.webp", content_type: 'image/webp')

    delete_video(webp_video_tmpfile, mm, orig_video_tmpfile)
  end
  def video_encoding_settings
    {
      probesize: "100M", analyzeduration: "100M", compression_level: 6, quality: 90, preset: 'default',
      custom: %w(-loop -0 -vf fps=20 -vf scale=720:-1)
    }
  end
  def delete_video(webp_video_tmpfile, mm, orig_video_tmpfile)
    orig_video_tmpfile.close
    orig_video_tmpfile.unlink
    webp_video_tmpfile.close
    webp_video_tmpfile.unlink
    if mm.present?
      mm.destroy!
    end
  end
end
