class AdBroadcastWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform(campaign_id, action)
    campaign = Campaign.find(campaign_id)
    channels = campaign.boards.pluck(:slug)

    # build html to append
    ad = campaign.ad
    append_msg = ""
    ad.multimedia.each do |mm|
      html_code = "<img class='board-ad-inner' src='#{mm.service_url}' data-campaign='#{campaign.slug}' data-budget='#{campaign.budget}'>"
      append_msg.insert(-1, html_code)
    end


    channels.each do |channel|
      broadcast_to_boards(channel, action, append_msg, campaign.slug)
    end
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
