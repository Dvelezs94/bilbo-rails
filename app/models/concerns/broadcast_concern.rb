module BroadcastConcern
  extend ActiveSupport::Concern

  # Publish ad function, this gets triggered when the state and status are true
  def publish_campaign(campaign_id, board_id)
    AdBroadcastWorker.perform_async(campaign_id, board_id, "enable")
  end

  # Remove ad function, this gets triggered when the state or status are false
  def remove_campaign(campaign_id, board_id)
    AdBroadcastWorker.perform_async(campaign_id, board_id, "disable")
  end

end
