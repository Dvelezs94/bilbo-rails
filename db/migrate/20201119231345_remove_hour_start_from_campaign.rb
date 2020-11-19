class RemoveHourStartFromCampaign < ActiveRecord::Migration[6.0]
  def change
    remove_column :campaigns, :hour_start, :time
  end
end
