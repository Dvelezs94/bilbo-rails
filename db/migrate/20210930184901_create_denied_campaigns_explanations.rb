class CreateDeniedCampaignsExplanations < ActiveRecord::Migration[6.0]
  def change
    create_table :denied_campaigns_explanations do |t|
      t.integer :message
      t.references :boards_campaigns, null: false, foreign_key: true

      t.timestamps
    end
  end
end
