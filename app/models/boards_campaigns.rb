class BoardsCampaigns < ApplicationRecord
    include BroadcastConcern
    include NotificationsHelper
    belongs_to :campaign
    belongs_to :board

    enum status: { just_created: 0, in_review: 1, approved: 2, denied: 3 }
    before_save :notify_users, if: :will_save_change_to_status?
    after_update :stop_campaign

    private
    def stop_campaign
      board.update_ads_rotation(campaign)
    end

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
end
