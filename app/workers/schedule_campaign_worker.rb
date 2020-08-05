class ScheduleCampaignWorker
  include Sidekiq::Worker
  include BroadcastConcern
  sidekiq_options retry: 5, dead: false
  def perform(campaign_id, board_id)
    bc = BoardsCampaigns.where(campaign_id: campaign_id, board_id: board_id, status: "approved")
    if bc.any?
      campaign = bc.campaign
      board = bc.board
      err = board.update_ads_rotation(campaign)
      #maybe put a notification for user if fails (err.any?)
    end
  end
end
