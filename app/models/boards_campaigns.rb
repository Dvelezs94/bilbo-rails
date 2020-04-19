class BoardsCampaigns < ApplicationRecord
    include BroadcastConcern
    belongs_to :campaign
    belongs_to :board

    enum status: { just_created: 0, in_review: 1, approved: 2, denied: 3 }
    before_save :update_broadcast, if: :status_changed?

    def update_broadcast
      if approved? && campaign.status.present?
        publish_campaign(campaign_id, board_id)
      else
        remove_campaign(campaign_id, board_id)
      end
    end
end
