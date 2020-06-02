class ScheduleCampaignWorker
  include Sidekiq::Worker
  include BroadcastConcern
  sidekiq_options retry: 5, dead: false
  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)
    if campaign.should_run?
      BoardsCampaigns.where(campaign_id: campaign.id).approved.pluck(:board_id).each do |board_id|
          publish_campaign(campaign.id, board_id)
      end
    else
      raise StandardError.new "Exception because the campaign can't run and it will try should do it again"
    end
  end



end
