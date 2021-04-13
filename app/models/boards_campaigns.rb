class BoardsCampaigns < ApplicationRecord
    include BroadcastConcern
    include NotificationsHelper
    attr_accessor :board_errors, :make_broadcast, :owner_updated_campaign, :update_remaining_impressions
    has_many :contents_board_campaign, class_name: "ContentsBoardCampaign", dependent: :delete_all
    belongs_to :campaign
    belongs_to :board
    belongs_to :sale, optional: true
    enum status: { in_review: 0, approved: 1, denied: 2 }
    before_create :set_price
    before_save :notify_users, if: :will_save_change_to_status?
    before_update :calculate_remaining_impressions
    after_commit :add_or_stop_campaign, if: :make_broadcast


    amoeba do
      enable
      include_association :contents_board_campaign, class_name: "ContentsBoardCampaign"
    end

    private

    def add_or_stop_campaign
      err = board.broadcast_to_board(campaign)
      if err.present?
        campaign.update(state: false)
        self.board_errors = err
      end
    end

    def calculate_remaining_impressions
      # Initialize or compute the remaining_impressions field from BoardsCampaigns
      if (status_changed?(to: "approved") || update_remaining_impressions)
        c = self.campaign
        b = self.board
        if c.classification == "budget"
          st = Time.zone.parse(b.start_time.strftime("%H:%M"))
          et = Time.zone.parse(b.end_time.strftime("%H:%M"))
          current_time = Time.zone.now + 15.seconds
          et += 1.day if et<=st and current_time >= et
          st -= 1.day if et<=st and current_time < et
          #Count impressions already created from the current ads rotation
          impression_count = current_time.between?(st,et)? c.daily_impressions(start_date: st, end_date: et, board_id: b.id) : {}
          today_impressions = impression_count.present?? impression_count.values.sum : 0
          max_imp = (c.budget_per_bilbo/(b.get_cycle_price(c, self) * c.duration/b.duration)).to_i
          ######################################Cambiar esto
          # max_imp = (c.budget_per_bilbo/(b.get_cycle_price(c, self) * 10/b.duration)).to_i
          self.remaining_impressions = max_imp - today_impressions

        elsif c.classification == "per_hour"
          st = Time.zone.parse(b.start_time.strftime("%H:%M"))
          et = Time.zone.parse(b.end_time.strftime("%H:%M"))
          current_time = Time.zone.now + 15.seconds
          et += 1.day if et<=st and current_time >= et
          st -= 1.day if et<=st and current_time < et
          #Count impressions already created from the current ads rotation
          impression_count = current_time.between?(st,et)? c.daily_impressions(start_date: st, end_date: et, board_id: b.id) : {}
          today_impressions =impression_count.present?? impression_count.values.sum : 0
          #Compute the total impressions that must be created in the current ads rotation and the difference with the impressions already created
          today_max_imp = c.impression_hours.select{|cpn| self.board.should_run_hour_campaign_in_board?(cpn) }.pluck(:imp).sum
          self.remaining_impressions = today_max_imp - today_impressions

        end
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
