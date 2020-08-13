class AdBroadcastWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false
  include Rails.application.routes.url_helpers

  def perform(campaign_id, board_id,action)
    board = Board.find(board_id)
    board.with_lock do
      campaign = Campaign.find(campaign_id)
      # build html to append
      ad = campaign.ad
      append_msg = ""
      ad.multimedia.each do |mm|
        html_code = "<img class='board-ad-inner' src='#{polymorphic_path(mm)}' data-campaign='#{campaign.slug}' data-campaign-id='#{campaign.id}' data-budget='#{campaign.budget}'>"
        append_msg.insert(-1, html_code)
      end
      broadcast_to_boards(board.slug, action, append_msg, campaign.slug, board.add_bilbo_campaigns.to_s)
    end
  end

  private
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
