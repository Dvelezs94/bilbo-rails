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
        begin
            retries ||= 0
            puts "attempt to convert video number ##{ retries }"
          if video.content_type == "video/mp4"
            orig_video_tmpfile = Tempfile.new(["#{video.blob.key}", ".mp4"], "tmp/multimedia")
          else
            orig_video_tmpfile = Tempfile.new(["#{video.blob.key}", ".avi"], "tmp/multimedia")
          end
          mp4_video_tmpfile = Tempfile.new(["#{video.blob.key}", ".mp4"], "tmp/multimedia")

          File.open(orig_video_tmpfile, 'wb') do |f|
            f.write(video.download)
          end

          movie = FFMPEG::Movie.new(orig_video_tmpfile.path)
          if meta[:height] > 1080
            movie.transcode(mp4_video_tmpfile.path, video_encoding_settings)
          else
            movie.transcode(mp4_video_tmpfile.path)
          end

          ad.multimedia.attach(io: File.open(mp4_video_tmpfile), filename: "#{video.blob.filename.base}.mp4", content_type: 'video/mp4')
          ad.multimedia.last.update(processed: true)
          delete_video(mp4_video_tmpfile, video, orig_video_tmpfile)

        rescue => e
          Bugsnag.notify(e)
          delete_video(mp4_video_tmpfile, video, orig_video_tmpfile)
          retry if (retries += 1) < 4
          puts "Conversion video failed"
          delete_video(mp4_video_tmpfile, video, orig_video_tmpfile)
        end
      elsif video.content_type = "video/mp4" && meta[:height] <= 1080
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
  def delete_video(mp4_video_tmpfile, mm, orig_video_tmpfile)
    if orig_video_tmpfile.present?
      orig_video_tmpfile.close
      orig_video_tmpfile.unlink
    end
    if mp4_video_tmpfile.present?
      mp4_video_tmpfile.close
      mp4_video_tmpfile.unlink
    end
    if mm.present?
      mm.destroy!
    end
  end
end
