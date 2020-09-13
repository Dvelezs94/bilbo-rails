class CreateCampaignSubscribers < ActiveRecord::Migration[6.0]
  def change
    create_table :campaign_subscribers do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :name
      t.string :phone

      t.timestamps
    end
  end
end
