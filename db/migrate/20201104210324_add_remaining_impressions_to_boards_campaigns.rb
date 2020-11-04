class AddRemainingImpressionsToBoardsCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :boards_campaigns, :remaining_impressions, :integer
  end
end
