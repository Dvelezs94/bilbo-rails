class UpdateRemainingImpressionsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    BoardsCampaigns.includes(:campaign).all.update(update_remaining_impressions: true)
    Board.all.each do |board|
    ActionCable.server.broadcast(
      board.slug,
      action: "update_rotation",
      ads_rotation: board.add_bilbo_campaigns.to_s,
      remaining_impressions: board.get_user_remaining_impressions.to_s
    )
    p "All user remaining impressions have been reseted"
  end
end
