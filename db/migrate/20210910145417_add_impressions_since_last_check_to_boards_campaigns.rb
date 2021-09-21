class AddImpressionsSinceLastCheckToBoardsCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :boards_campaigns, :impressions_since_last_check, :integer, default: 0
  end
end
