class AdBroadcastWorker
  include Sidekiq::Worker
  include AdRotationAlgorithm
  sidekiq_options retry: false, dead: false
  include Rails.application.routes.url_helpers

  def perform(campaign_id, board_id,action)
    campaign = Campaign.find(campaign_id)
    board = Board.find(board_id)
    update_ad_rotation(board)

    # build html to append
    ad = campaign.ad
    append_msg = ""
    ad.multimedia.each do |mm|
      html_code = "<img class='board-ad-inner' src='#{polymorphic_path(mm)}' data-campaign='#{campaign.slug}' data-campaign-id='#{campaign.id}' data-budget='#{campaign.budget}'>"
      append_msg.insert(-1, html_code)
    end

    broadcast_to_boards(board.slug, action, append_msg, campaign.slug, board.ads_rotation)
  end

  private

  def update_ad_rotation(board)
    # build the ad rotation because the ads changed
    new_cycle = board.build_ad_rotation(board)
    board.update(ads_rotation: new_cycle)
  end

  def broadcast_to_boards(channel, action, ad, campaign_slug, ads_rotation)
    ActionCable.server.broadcast(
      channel,
      action: action,
      campaign_slug: campaign_slug,
      ad: ad,
      ads_rotation: ads_rotation
    )
  end
end
