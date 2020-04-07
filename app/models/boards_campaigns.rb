class BoardsCampaigns < ApplicationRecord
    belongs_to :campaign
    belongs_to :board

    enum status: { just_created: 0, in_review: 1, approved: 2, denied: 3 }
    before_save :update_broadcast, if: :status_changed?

    def update_broadcast
      if status_changed?
        if approved?
          publish_campaign
        else
          remove_campaign
        end
      end
    end

    # Publish ad function, this gets triggered when the state and status are true
    def publish_campaign
      AdBroadcastWorker.perform_async(campaign_id, board_id, "enable")
    end

    # Remove ad function, this gets triggered when the state or status are false
    def remove_campaign
      AdBroadcastWorker.perform_async(campaign_id, board_id, "disable")
    end
end
