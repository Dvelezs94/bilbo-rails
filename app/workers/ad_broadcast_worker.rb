class AdBroadcastWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false
  include Rails.application.routes.url_helpers

  def perform(campaign_id, board_id,action)
    campaign = Campaign.find(campaign_id)
    board_channel = Board.find(board_id).slug

    # build html to append
    ad = campaign.ad
    append_msg = ""
    ad.multimedia.each do |mm|
      html_code = "<img class='board-ad-inner' src='#{polymorphic_path(mm)}' data-campaign='#{campaign.slug}' data-campaign-id='#{campaign.id}' data-budget='#{campaign.budget}'>"
      append_msg.insert(-1, html_code)
    end

    broadcast_to_boards(board_channel, action, append_msg, campaign.slug)
  end

  private

  def broadcast_to_boards(channel, action, ad, campaign_slug)
    ActionCable.server.broadcast(
      channel,
      action: action,
      campaign_slug: campaign_slug,
      ad: ad
    )
  end
end
