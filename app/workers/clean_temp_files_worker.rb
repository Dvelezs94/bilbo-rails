class CleanTempFilesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    system('find tmp/multimedia -type f -mmin +30 -delete')
  end
end
