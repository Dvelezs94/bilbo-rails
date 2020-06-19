class RegerateAdsRotationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    Board.enabled.to_a.select(&:update_ad_rotation)
  end
end
