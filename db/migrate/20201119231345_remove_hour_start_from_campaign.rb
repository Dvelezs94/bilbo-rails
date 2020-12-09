class RemoveHourStartandHourFinishFromCampaign < ActiveRecord::Migration[6.0]
  def change
    remove_column :campaigns, :hour_start, :time
    remove_column :campaigns, :hour_finish, :time
  end
end
