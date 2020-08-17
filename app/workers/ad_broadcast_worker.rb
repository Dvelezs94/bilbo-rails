class AdBroadcastWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false
  include Rails.application.routes.url_helpers

  def perform(campaign_id, board_id,action)
    board = Board.find(board_id)
    board.with_lock do
      campaign = Campaign.find(campaign_id)
      append_msg = ApplicationController.renderer.render(partial: "campaigns/board_campaign", collection: campaign.ad.multimedia, locals: {campaign: campaign},as: :media)
      # build html to append
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
