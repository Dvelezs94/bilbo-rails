class CreateJoinTableAdCampaign < ActiveRecord::Migration[5.2]
  def change
    create_join_table :ads, :campaigns do |t|
      t.index [:ad_id, :campaign_id]
      t.index [:campaign_id, :ad_id]
    end
  end
end
