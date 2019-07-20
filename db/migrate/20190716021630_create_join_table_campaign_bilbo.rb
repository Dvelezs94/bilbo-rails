class CreateJoinTableCampaignBilbo < ActiveRecord::Migration[5.2]
  def change
    create_join_table :campaigns, :bilbos do |t|
      t.index [:campaign_id, :bilbo_id]
      t.index [:bilbo_id, :campaign_id]
    end
  end
end
