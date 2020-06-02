class AddProviderCampaignToCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_column :campaigns, :provider_campaign, :boolean
  end
end
