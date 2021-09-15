class AddApprovalMonitoringToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :approval_monitoring, :string
  end
end
