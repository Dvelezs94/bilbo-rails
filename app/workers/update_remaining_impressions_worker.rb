class UpdateRemainingImpressionsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    BoardsCampaigns.includes(:campaign).all.update(update_remaining_impressions: true)
    Board.all.select{|b| b.connected?}.each do |board|
      ActionCable.server.broadcast(
        board.slug,
        action: "update_rotation",
        ads_rotation: board.add_bilbo_campaigns.to_s,
      )
    end
    p "All user remaining impressions have been reseted, online boards have been updated"
  end
end
