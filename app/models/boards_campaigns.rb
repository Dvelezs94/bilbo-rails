class BoardsCampaigns < ApplicationRecord
    include BroadcastConcern
    include NotificationsHelper
    attr_accessor :board_errors, :make_broadcast
    belongs_to :campaign
    belongs_to :board

    enum status: { in_review: 0, approved: 1, denied: 2 }
    before_save :notify_users, if: :will_save_change_to_status?
    after_update :add_or_stop_campaign, if: :make_broadcast

    private
    def add_or_stop_campaign
      err = board.broadcast_to_board(campaign)
      if err.present?
        campaign.update(state: false)
        self.board_errors = err
      end
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
