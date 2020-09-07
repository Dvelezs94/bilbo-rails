class AddAnalyticsTokenToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :analytics_token, :string
  end
end
