class AdBroadcastWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false
  include Rails.application.routes.url_helpers

  def perform(campaign_id, board_id,action)
    board = Board.find(board_id)
    board.with_lock do
      campaign = Campaign.find(campaign_id)
      content_bc = ContentsBoardCampaign.where(boards_campaigns_id: BoardsCampaigns.find_by(board: board, campaign: campaign).id).pluck(:content_id)
      content = Content.where(id: content_bc)
      if board.images_only
        append_msg = ApplicationController.renderer.render(partial: "campaigns/board_campaign", collection: content.select{|c| c.multimedia.content_type.include? "image"}, as: :media, locals: {campaign: campaign, board: board})
      else
        append_msg = ApplicationController.renderer.render(partial: "campaigns/board_campaign", collection: content, as: :media, locals: {campaign: campaign, board: board})
      end

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
