class AddDurationToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :duration, :integer, default: 10
  end
end
