class AddSalesAndRemainingImpressionsToBoardsCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_reference :boards_campaigns, :sale, foreign_key: true
    add_column :boards_campaigns, :remaining_impressions, :integer, default: 0
  end
end
