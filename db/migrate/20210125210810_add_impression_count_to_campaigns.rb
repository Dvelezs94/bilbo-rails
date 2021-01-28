class AddImpressionCountToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :impression_count, :integer, default: 0
  end
end
