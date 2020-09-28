class VideoConverterWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3, dead: false
  require 'streamio-ffmpeg'
  def perform(ad_id)
    ad = Ad.find(ad_id)

    ad.videos.each do |video|
      if !video.processed && video.content_type == "video/x-msvideo" || video.content_type == "video/msvideo" || video.content_type == "video/avi"
        puts "x" * 500
        puts video.filename
        orig_video_tmpfile = Tempfile.new(["#{video.blob.key}", ".avi"])
        mp4_video_tmpfile = Tempfile.new(["#{video.blob.key}", ".mp4"])
        File.open(orig_video_tmpfile, 'wb') do |f|
          f.write(video.download)
        end
        movie = FFMPEG::Movie.new(orig_video_tmpfile.path)
        p "m" * 800
        p movie.height
        if movie.height.to_i > 1080
          p "more than 1920"
          movie.transcode(mp4_video_tmpfile.path, video_encoding_settings)
        else
          p "nel pastel"
          movie.transcode(mp4_video_tmpfile.path)
        end
        ad.multimedia.attach(io: File.open(mp4_video_tmpfile), filename: "#{video.blob.filename.base}.mp4", content_type: 'video/mp4')
        ad.multimedia.last.update(processed: true)
      delete_video(mp4_video_tmpfile, video ,orig_video_tmpfile)
      else
        video.update(processed: true)
      end
    end
  end
  def video_encoding_settings
    {
      #probesize: "100M", analyzeduration: "100M", compression_level: 6, quality: 90, preset: 'default',
      custom: %w(-vf scale=-1:1080)
    }
  end
  def delete_video(mp4_video_tmpfile, mm ,orig_video_tmpfile)
    orig_video_tmpfile.close
    orig_video_tmpfile.unlink
    mp4_video_tmpfile.close
    mp4_video_tmpfile.unlink
    if mm.present?
      mm.destroy!
    end
  end
end
