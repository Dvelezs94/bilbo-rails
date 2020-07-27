class AddMinutesAndHoursImpressionsToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :minutes, :integer
    add_column :campaigns, :impressions, :integer
    add_column :campaigns, :hour_start, :time
    add_column :campaigns, :hour_finish, :time
  end
end
