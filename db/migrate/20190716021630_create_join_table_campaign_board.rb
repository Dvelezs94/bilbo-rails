class CreateJoinTableCampaignBoard < ActiveRecord::Migration[5.2]
  def change
    create_join_table :campaigns, :boards do |t|
      t.index [:campaign_id, :board_id]
      t.index [:board_id, :campaign_id]
      t.integer :status, null: false, default: 0
    end
  end
end
