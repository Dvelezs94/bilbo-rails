class AddCyclePriceToBoardsCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :boards_campaigns, :cycle_price, :float
  end
end
