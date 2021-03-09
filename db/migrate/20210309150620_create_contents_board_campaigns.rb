class CreateContentsBoardCampaigns < ActiveRecord::Migration[6.0]
  def change
    create_table :contents_board_campaigns do |t|
      t.references :content, null: false, foreign_key: true
      t.references :boards_campaigns, null: false, foreign_key: true

      t.timestamps
    end
  end
end
