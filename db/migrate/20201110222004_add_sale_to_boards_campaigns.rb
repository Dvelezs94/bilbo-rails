class AddSaleToBoardsCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_reference :boards_campaigns, :sale, foreign_key: true
  end
end
