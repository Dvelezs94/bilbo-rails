class CreateCampaignDenials < ActiveRecord::Migration[5.2]
  def change
    create_table :campaign_denials do |t|
      t.references :campaign, foreign_key: true
      t.string :comment

      t.timestamps
    end
  end
end
