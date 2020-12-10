module ReviewBoardCampaignsConcern
  extend ActiveSupport::Concern

  def set_in_review_boards_and_update_price(campaign, have_to_set_in_review_on_boards, owner_updated_campaign)
    campaign.board_campaigns.each do |bc|
      attr = {}
      attr.merge!({status: "in_review"}) if have_to_set_in_review_on_boards
      attr.merge!({cycle_price: bc.board.cycle_price, sale: bc.board.current_sale, update_remaining_impressions: true}) if owner_updated_campaign
      bc.update(attr) if attr.any?
    end
  end

end
