class VideoConverterWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false
  require 'streamio-ffmpeg'

  def perform(ad_id, mm_id)
    puts "x" * 500
    ad = Ad.find(ad_id)
    mm = ad.multimedia.find(video_id)
    mm.open do |orig_video_tmpfile|
      webp_video_tmpfile = Tempfile.new(mm.blob.key, ".webp")

      movie = FFMPEG::Movie.new(orig_video_tmpfile)
      movie.transcode(webp_video_tmpfile.path, video_encoding_settings)

      ad.multimedia.attach(io: File.open(webp_video_tmpfile), filename: "#{mm.blob.filename.base}.webp", content_type: 'image/webp')
    end
    delete_video(webp_video_tmpfile, mm)
  end

  def video_encoding_settings
    %w(-probesize 100M -analyzeduration 100M -compression_level 6 -q:v 90 -preset default -loop 0 -vf fps=20, scale=720:-1)
  end

  def delete_video(webp_video_tmpfile, mm)
    webp_video_tmpfile.close
    webp_video_tmpfile.unlink

    if mm.present?
      mm.destroy!
    end
  end
end
