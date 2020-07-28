class AddTypeOfCampaignToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :clasification, :integer, default: 0
  end
end
