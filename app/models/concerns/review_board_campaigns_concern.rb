module ReviewBoardCampaignsConcern
  extend ActiveSupport::Concern

  def set_in_review_boards_and_update_price(campaign, have_to_set_in_review_on_boards, owner_updated_campaign,extra_percentage = 20)
    distribution = campaign.budget_distribution.present?? JSON.parse(campaign.budget_distribution) : nil
    campaign.board_campaigns.each do |bc|
      attr = {}
      attr.merge!({status: "in_review"}) if have_to_set_in_review_on_boards
      #Add an extra price for user campaigns per hour
      base_price = bc.board.cycle_price
      price =  (bc.campaign.classification == "per_hour" and !bc.campaign.provider_campaign?)? base_price*(1+extra_percentage/100.0) : base_price
      attr.merge!({budget: distribution[bc.board.id.to_s]}) if distribution.present?
      attr.merge!({cycle_price: price, sale: bc.board.current_sale, update_remaining_impressions: true}) if owner_updated_campaign
      bc.update(attr) if attr.any?
    end
    #Set a sidekiq worker to check if the campaign was approved in a day
    if !campaign.approval_monitoring.present?
      worker_id = MonitorCampaignsWorker.perform_at(1.day.from_now, mode = "check approval", campaign_id = campaign.id)
      campaign.update_column(:approval_monitoring, worker_id)
    end
  end

end
