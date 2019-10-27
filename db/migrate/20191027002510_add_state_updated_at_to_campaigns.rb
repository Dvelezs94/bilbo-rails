class AddStateUpdatedAtToCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_column :campaigns, :state_updated_at, :datetime
  end
end
