class RemoveScheduleCampaignWorker
  include Sidekiq::Worker
  include BroadcastConcern
  include NotificationsHelper
  sidekiq_options retry: 5, dead: false
  def perform(campaign_id, board_id)
    bc = BoardsCampaigns.find_by(campaign_id: campaign_id, board_id: board_id, status: "approved")
    if bc.present?
      campaign = bc.campaign
      campaign.with_lock do
        if campaign.state && !campaign.time_to_run?(bc.board)
          campaign.update(state: false)
        end
      end
    end
  end
end
