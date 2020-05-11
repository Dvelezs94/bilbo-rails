class BoardsCampaigns < ApplicationRecord
    include BroadcastConcern
    belongs_to :campaign
    belongs_to :board

    enum status: { just_created: 0, in_review: 1, approved: 2, denied: 3 }
    after_save :update_broadcast

    def update_broadcast
      update_ad_rotation
      if approved? && campaign.status.present?
        publish_campaign(campaign_id, board_id)
      else
        remove_campaign(campaign_id, board_id)
      end
    end

    private

    def update_ad_rotation
      # build the ad rotation because the ads changed
      new_cycle = self.board.build_ad_rotation(self.board)
      board.update(ads_rotation: new_cycle)
    end
end
