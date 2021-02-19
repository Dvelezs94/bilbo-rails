class AddTotalInvestedToCampaign < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :total_invested, :float, default: 0.0
  end
end
