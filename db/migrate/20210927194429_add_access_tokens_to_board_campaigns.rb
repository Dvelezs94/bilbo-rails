class AddAccessTokensToBoardCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :boards_campaigns, :access_token, :string
  end
end
