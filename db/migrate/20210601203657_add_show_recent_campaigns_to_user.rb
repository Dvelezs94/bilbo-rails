class AddShowRecentCampaignsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :show_recent_campaigns, :boolean, default: true
  end
end
