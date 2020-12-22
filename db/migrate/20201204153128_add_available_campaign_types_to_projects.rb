class AddAvailableCampaignTypesToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :available_campaign_types, :string, default: '["budget"]'
  end
end
