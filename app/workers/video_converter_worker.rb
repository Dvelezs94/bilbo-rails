class VideoConverterWorker
  include Sidekiq::Worker
  include ApplicationHelper
  sidekiq_options retry: 3, dead: false
  require 'streamio-ffmpeg'
  def perform(ad_id)
    ad = Ad.find(ad_id)
    ad.videos.each do |video|
      meta = get_image_size_from_metadata(video)
      if !video.processed && video.content_type == "video/x-msvideo" || video.content_type == "video/msvideo" || video.content_type == "video/avi" || meta[:height] > 1080
        if video.content_type == "video/mp4"
          orig_video_tmpfile = Tempfile.new(["#{video.blob.key}", ".mp4"])
        else
          orig_video_tmpfile = Tempfile.new(["#{video.blob.key}", ".avi"])
        end
        mp4_video_tmpfile = Tempfile.new(["#{video.blob.key}", ".mp4"])

        File.open(orig_video_tmpfile, 'wb') do |f|
          f.write(video.download)
        end

        movie = FFMPEG::Movie.new(orig_video_tmpfile.path)
        if movie.height.to_i > 1080
          movie.transcode(mp4_video_tmpfile.path, video_encoding_settings)
        else
          movie.transcode(mp4_video_tmpfile.path)
        end

        ad.multimedia.attach(io: File.open(mp4_video_tmpfile), filename: "#{video.blob.filename.base}.mp4", content_type: 'video/mp4')
        ad.multimedia.last.update(processed: true)
        delete_video(mp4_video_tmpfile, video, orig_video_tmpfile)
      elsif video.content_type= "video/mp4" && meta[:height] <= 1080
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
