class BoardsCampaigns < ApplicationRecord
    include BroadcastConcern
    include NotificationsHelper
    attr_accessor :board_errors, :make_broadcast, :owner_updated_campaign, :update_remaining_impressions
    belongs_to :campaign
    belongs_to :board
    belongs_to :sale, optional: true
    enum status: { in_review: 0, approved: 1, denied: 2 }
    before_create :set_price
    before_save :notify_users, if: :will_save_change_to_status?
    before_update :calculate_remaining_impressions
    after_update :add_or_stop_campaign, if: :make_broadcast

    private
    def add_or_stop_campaign
      err = board.broadcast_to_board(campaign)
      if err.present?
        campaign.update(state: false)
        self.board_errors = err
      end
    end

    def calculate_remaining_impressions
      # Initialize or compute the remaining_impressions field from BoardsCampaigns (for user campaigns)
      c = self.campaign
      b = self.board
      impression_count = c.daily_impressions(Time.now.beginning_of_day .. Time.now.end_of_day, b.id)
      today_impressions = impression_count.present?? impression_count.values[0] : 0
      if (status_changed?(to: "approved") || update_remaining_impressions) and campaign.clasification == "budget"
        duration_of_ad = c.provider_campaign?? c.ad.duration : b.duration #providers use  its own duration and users the duration of bilbo always
        max_imp = (c.budget_per_bilbo/(b.get_cycle_price(c, self) * duration_of_ad/b.duration)).to_i
        self.remaining_impressions = max_imp - today_impressions
      elsif (status_changed?(to: "approved") || update_remaining_impressions) and campaign.clasification == "per_hour"
        today_max_imp = c.impression_hours.select{|cpn| self.board.should_run_hour_campaign_in_board?(cpn) }.pluck(:imp).sum
        self.remaining_impressions = today_max_imp - today_impressions
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

    def set_price
      self.cycle_price = self.board.cycle_price
      self.sale_id = (self.board.current_sale.present?)? self.board.current_sale.id : nil
    end
end
