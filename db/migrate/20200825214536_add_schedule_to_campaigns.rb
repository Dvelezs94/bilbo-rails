class AddScheduleToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :schedule, :text
  end
end
