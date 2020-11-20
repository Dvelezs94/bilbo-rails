class AddRemainingImpressionsAndSalesToBoardsCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :boards_campaigns, :remaining_impressions, :integer, default: 0
    add_reference :boards_campaigns, :sale, foreign_key: true
  end
end
