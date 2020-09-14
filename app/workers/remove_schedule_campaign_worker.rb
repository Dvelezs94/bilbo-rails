class RemoveScheduleCampaignWorker
  include Sidekiq::Worker
  include BroadcastConcern
  include NotificationsHelper
  sidekiq_options retry: 5, dead: false
  def perform(campaign_id, board_id)
    campaign = Campaign.find(campaign_id)
    campaign.with_lock do
      return if !campaign.state
      bc = BoardsCampaigns.includes(:board).where(campaign_id: campaign_id,status: "approved")
      bc.each do |element|
        board = element.board
        if campaign.should_run?(board)
          return #end execution, dont turn off because at least in one board is active
        end
      end
      campaign.update(state: false)
    end
  end
end
