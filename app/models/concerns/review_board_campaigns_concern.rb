module ReviewBoardCampaignsConcern
  extend ActiveSupport::Concern

  def set_in_review_boards_and_update_price(campaign, have_to_set_in_review_on_boards, owner_updated_campaign,extra_percentage = 20)
    campaign.board_campaigns.each do |bc|
      attr = {}
      attr.merge!({status: "in_review"}) if have_to_set_in_review_on_boards
      #Add an extra price for user campaigns per hour
      base_price = bc.board.cycle_price
      price =  (bc.campaign.clasification == "per_hour" and !bc.campaign.provider_campaign?)? base_price*(1+extra_percentage/100.0) : base_price

      attr.merge!({cycle_price: price, sale: bc.board.current_sale, update_remaining_impressions: true}) if owner_updated_campaign
      bc.update(attr) if attr.any?
    end
  end

end
