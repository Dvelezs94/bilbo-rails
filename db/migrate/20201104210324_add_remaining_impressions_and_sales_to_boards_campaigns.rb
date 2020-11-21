class AddRemainingImpressionsAndSalesToBoardsCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :boards_campaigns, :remaining_impressions, :integer, default: 0
  end
end
