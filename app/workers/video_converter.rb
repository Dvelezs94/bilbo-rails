class VideoConverter
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false
  require 'streamio-ffmpeg'
  def perform(ad_id,video_id)
    video = Ad.find(ad_id).multimedia.find(video_id)
    orig_video_tmpfile = "#{Rails.root}/tmp/#{video.blob.key}_#{video.blob.filename.to_s}"
    webp_video_tmpfile = "#{Rails.root}/tmp/#{video.blob.key}_#{video.blob.filename.base}.webp"
    cut_video_tmpfile = "#{Rails.root}/tmp/#{video.blob.key}_cut_#{video.blob.filename.to_s}"
    File.open(orig_video_tmpfile, 'wb') do |f|
      f.write(video.download)
    end
    begin
      movie = FFMPEG::Movie.new(orig_video_tmpfile)
      if movie.duration > 10
        system('ffmpeg', '-i', orig_video_tmpfile, '-ss', "00:00:00", '-to', "00:00:10",'-c', "copy", cut_video_tmpfile)
        system('ffmpeg', '-probesize', "100M", '-analyzeduration', "100M", '-i', cut_video_tmpfile, '-compression_level', "6", '-q:v', "90",  '-preset', "default", '-loop', "0", '-vf', "fps=20, scale=720:-1", webp_video_tmpfile)
        File.delete(cut_video_tmpfile)
      else
        system('ffmpeg', '-probesize', "100M", '-analyzeduration', "100M", '-i', orig_video_tmpfile, '-compression_level', "6", '-q:v', "90",  '-preset', "default", '-loop', "0", '-vf', "fps=20, scale=720:-1", webp_video_tmpfile)
      end
      Ad.find(ad_id).multimedia.attach(io: File.open(webp_video_tmpfile), filename: "#{video.blob.filename.base}.webp", content_type: 'image/webp')
      delete_video(orig_video_tmpfile, webp_video_tmpfile, video)
    rescue
      delete_video(orig_video_tmpfile, webp_video_tmpfile, video)
  end
end

  def delete_video(orig_video_tmpfile, webp_video_tmpfile, video)
    File.delete(orig_video_tmpfile)
    File.delete(webp_video_tmpfile)

    if video.present?
      video.destroy!
    end
  end
end
