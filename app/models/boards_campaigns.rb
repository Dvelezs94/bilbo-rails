class BoardsCampaigns < ApplicationRecord
    include BroadcastConcern
    include NotificationsHelper
    belongs_to :campaign
    belongs_to :board

    enum status: { just_created: 0, in_review: 1, approved: 2, denied: 3 }
    before_save :notify_users, if: :will_save_change_to_status?
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

    def notify_users
      if in_review?
        campaign.boards.includes(:project).map(&:project).uniq.each do |provider|
          create_notification(recipient_id: provider.id, actor_id: campaign.project.id,
                              action: "created", notifiable: campaign)
        end
      elsif approved?
        create_notification(recipient_id: campaign.project.id, actor_id: board.project.id,
                            action: "approved", notifiable: campaign,
                            reference: board)
      elsif denied?
        create_notification(recipient_id: campaign.project.id, actor_id: board.project.id,
                            action: "denied", notifiable: campaign,
                            reference: board)
      end
    end

    def update_ad_rotation
      # build the ad rotation because the ads changed
      new_cycle = self.board.build_ad_rotation(self.board)
      board.update(ads_rotation: new_cycle)
    end
end
