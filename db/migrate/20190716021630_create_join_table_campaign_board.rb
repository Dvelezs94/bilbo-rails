class CreateJoinTableCampaignBoard < ActiveRecord::Migration[5.2]
  def change
    create_join_table :campaigns, :boards do |t|
      # t.index [:campaign_id, :board_id]
      # t.index [:board_id, :campaign_id]
    end
  end
end
