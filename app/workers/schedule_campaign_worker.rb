class ScheduleCampaignWorker
  include Sidekiq::Worker
  include BroadcastConcern
  include NotificationsHelper
  sidekiq_options retry: 5, dead: false
  def perform(campaign_id, board_id)
    bc = BoardsCampaigns.find_by(campaign_id: campaign_id, board_id: board_id, status: "approved")
    if bc.present?
      campaign = bc.campaign
      campaign.with_lock do
        if campaign.state
          board = bc.board
          err = board.update_ads_rotation(campaign)
          if err.present?
            campaign.update(state: false)
            create_notification(recipient_id: campaign.project.owner.id, actor_id: campaign.project.id , action: "time campaign error", notifiable: campaign)
          end
        end
      end
    end
  end
end
